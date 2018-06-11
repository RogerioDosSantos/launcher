
json::IsValid()
{
  # Usage IsValid <in:json>
  local in_json=$1

  echo "${in_json}" | python -m json.tool &> /dev/null && echo "true" || echo "false"
}

json::GetValue()
{
  # Usage GetValue <in:json> <in:value_name> [<in:format>]
  local in_json=$1
  local in_value_name=$2
  local in_format=$3

  local resp=""
  if [ "${in_format}" == "" ]; then
    resp="$(exec 2>1; echo "${in_json}" | jq ."${in_value_name}" ; echo "$?")"
    resp=${resp//\"/}
  else
    local format=""
    printf -v 'format' '.%s | @%s' "${in_value_name}" "${in_format}" 
    resp="$(exec 2>1; echo "${in_json}" | jq "${format}" ; echo "$?")"
  fi
  
  local error="${resp##*$'\n'}"
  if [ "${error}" == "1" ]; then
    return 0
  fi

  resp=$(echo "${resp}" | sed '$d')
  echo "${resp}"
}

json::VarsToJson()
{
  # Unage: VarsToJson <var_name>...
  local key=""
  local value=""
  local ret="{"
  while [[ $# > 1 ]]; do
    key=$1
    value="$(eval echo \$\{${key}\})"
    key="$(printf '%s' "${key}" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
    value="$(printf '%s' "${value}" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
    printf -v "ret" '%s\n  %s:%s,' "${ret}" "${key}" "${value}"
		shift 1
	done

  key=$1
  value="$(eval echo \$\{${key}\})"
  key="$(printf '%s' "${key}" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  value="$(printf '%s' "${value}" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  printf '%s\n  %s:%s\n}\n' "${ret}" "${key}" "${value}"
}

json::GetResult()
{
  # Usage GetResult <in:item>...
  local in_result=$(cat)
  local json_result="$(echo "${in_result}" | awk '/#-5390cc39fd0a1cddcc018d2ccce29762-#/{flag=1;next}/#-b987d9248ffed522a0a09e4ab278f748-#/{flag=0}flag')"
  if [ "$#" == 0 ]; then
    printf '%s\n' "${json_result}"
    return 0
  fi

  while [[ $# > 0 ]]; do
    local in_item=$1
    printf '%s\n' "${json_result}"

    # key="$(printf '%s' "$1" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
    # value="$(printf '%s' "$2" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
    # printf -v "ret" '%s\n  %s:%s,' "${ret}" "${key}" "${value}"

		shift 1
	done
}
