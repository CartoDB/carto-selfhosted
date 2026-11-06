#!/usr/bin/env bash

# Runs install.sh with a fake docker and docker-compose on PATH and checks the
# registry login it performs. Usage: tests/install_registry_login_test.sh

set -o errexit
set -o nounset
set -o pipefail

repo_dir=$(cd "$(dirname "$0")/.." && pwd)
work_dir=$(mktemp -d)
trap 'rm -rf "${work_dir}"' EXIT

fake_bin="${work_dir}/bin"
mkdir -p "${fake_bin}"
cat >"${fake_bin}/docker" <<'EOF'
#!/usr/bin/env bash
case "${1:-}" in
--version) echo "Docker version 27.0.0, build 0000000" ;;
login)
	printf '%s\n' "$*" >"${FAKE_DOCKER_DIR}/argv"
	cat >"${FAKE_DOCKER_DIR}/stdin"
	exit "${FAKE_DOCKER_LOGIN_EXIT}"
	;;
esac
EOF
cat >"${fake_bin}/docker-compose" <<'EOF'
#!/usr/bin/env bash
echo "Docker Compose version v2.27.0"
EOF
chmod +x "${fake_bin}/docker" "${fake_bin}/docker-compose"

docs_url="https://docs.carto.com/carto-self-hosted/configuration/security/authenticated-image-pulls"
finished_line="[INFO]: Script finished, run docker-compose up -d"
failures=0
case_dir=""
case_exit=0

# $1 case name, $2 registry in env.tpl, $3 registry in customer.env (empty to omit), $4 fake login exit code
run_case() {
	case_dir="${work_dir}/$1"
	mkdir -p "${case_dir}"
	sed "s|^DOCKER_REGISTRY_BASE_PATH=.*|DOCKER_REGISTRY_BASE_PATH=$2|" "${repo_dir}/env.tpl" >"${case_dir}/env.tpl"
	cp "${repo_dir}/VERSION" "${repo_dir}/MIN_VERSION" "${case_dir}/"
	{
		echo "CARTO_SELFHOSTED_CUSTOMER_PACKAGE_VERSION=$(cat "${repo_dir}/VERSION")"
		echo "POSTGRES_ADMIN_PASSWORD=secret"
		echo "LOCAL_POSTGRES_SCALE=0"
		if [ -n "$3" ]; then
			echo "DOCKER_REGISTRY_BASE_PATH=$3"
		fi
	} >"${case_dir}/customer.env"
	echo '{"type": "service_account", "private_key": "fake-private-key"}' >"${case_dir}/key.json"

	if (cd "${case_dir}" && FAKE_DOCKER_DIR="${case_dir}" FAKE_DOCKER_LOGIN_EXIT="$4" PATH="${fake_bin}:${PATH}" bash "${repo_dir}/install.sh" >"${case_dir}/output" 2>&1); then
		case_exit=0
	else
		case_exit=$?
	fi
}

check() {
	local description=$1
	shift
	if "$@"; then
		echo "ok - ${description}"
	else
		echo "FAIL - ${description}"
		failures=$((failures + 1))
	fi
}

absent() {
	! grep -q -- "$1" "$2"
}

run_case carto us-docker.pkg.dev/carto-onprem-artifacts/gcr.io "" 0
check "carto registry: install.sh exits 0" test "${case_exit}" -eq 0
check "carto registry: logs in to us-docker.pkg.dev" grep -qx 'login -u _json_key --password-stdin us-docker.pkg.dev' "${case_dir}/argv"
check "carto registry: key.json goes to stdin" diff "${case_dir}/key.json" "${case_dir}/stdin"
check "carto registry: key never on argv" absent fake-private-key "${case_dir}/argv"
check "carto registry: key never in output" absent fake-private-key "${case_dir}/output"
check "carto registry: reports the login" grep -q '^\[INFO\]: Logged in to us-docker.pkg.dev' "${case_dir}/output"
check "carto registry: tells which user runs docker-compose" grep -q '^\[INFO\]: Run docker-compose as user ' "${case_dir}/output"
check "carto registry: finished message is the last line" test "$(tail -n 1 "${case_dir}/output")" = "${finished_line}"

run_case legacy gcr.io/carto-onprem-artifacts "" 0
check "legacy registry: install.sh exits 0" test "${case_exit}" -eq 0
check "legacy registry: logs in to gcr.io" grep -qx 'login -u _json_key --password-stdin gcr.io' "${case_dir}/argv"

run_case mirror registry.example.com/carto "" 0
check "mirror registry: install.sh exits 0" test "${case_exit}" -eq 0
check "mirror registry: skips the login" test ! -e "${case_dir}/argv"
check "mirror registry: says credentials are the customer's" grep -q 'credentials are yours to manage' "${case_dir}/output"
check "mirror registry: finished message is the last line" test "$(tail -n 1 "${case_dir}/output")" = "${finished_line}"

run_case failed us-docker.pkg.dev/carto-onprem-artifacts/gcr.io "" 1
check "failed login: install.sh exits non-zero" test "${case_exit}" -ne 0
check "failed login: names the host" grep -q '^\[ERROR\]: Login to us-docker.pkg.dev failed' "${case_dir}/output"
check "failed login: links the docs" grep -qF "${docs_url}" "${case_dir}/output"
check "failed login: no finished message" absent 'Script finished' "${case_dir}/output"

run_case duplicate us-docker.pkg.dev/carto-onprem-artifacts/gcr.io registry.example.com/carto 0
check "duplicate key: last assignment wins, as in docker-compose" grep -qx 'login -u _json_key --password-stdin us-docker.pkg.dev' "${case_dir}/argv"

if [ "${failures}" -ne 0 ]; then
	echo "${failures} check(s) failed"
	exit 1
fi
echo "all checks passed"
