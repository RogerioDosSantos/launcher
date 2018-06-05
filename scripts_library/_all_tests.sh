
all_tests::Run()
{
  # Usage Run <in:test_name>
  local in_test_name=$1

  tests=$(echo "$(ls | grep -v "_all_tests.sh" | grep _tests.sh)")
  echo "${tests}" | while read -r test; do
    source "${test}"

    local dependency="${test/.sh/.dep}"
    source "${dependency}"

    local name=$(echo "${test/.sh/}")
    qa::Run "${name:1}"
  done
}

