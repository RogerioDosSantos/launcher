
helper::Return()
{
  # Unage: Return <name> <value>...
  # echo "#- 5390cc39fd0a1cddcc018d2ccce29762 -#"
  echo "#-5390cc39fd0a1cddcc018d2ccce29762-#"
	if [[ $(( $# % 2 )) != 0 ]];then
		printf '{\n  "error":"Invalid return!"\n}\n'
		log::Log "error" "1" "Invalid return" "$@"
		# echo "#- 5390cc39fd0a1cddcc018d2ccce29762 -#"
    echo "#-b987d9248ffed522a0a09e4ab278f748-#"
		exit 1
	fi

  local key=""
  local value=""
  local ret="{"
  while [[ $# > 2 ]]; do
    key="$(printf '%s' "$1" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
    value="$(printf '%s' "$2" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
    printf -v "ret" '%s\n  %s:%s,' "${ret}" "${key}" "${value}"
		shift 2
	done

  key="$(printf '%s' "$1" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  value="$(printf '%s' "$2" | python -c 'import json,sys; print(json.dumps(sys.stdin.read()))')"
  printf '%s\n  %s:%s\n}\n' "${ret}" "${key}" "${value}"
  # echo "#- 5390cc39fd0a1cddcc018d2ccce29762 -#"
  echo "#-b987d9248ffed522a0a09e4ab278f748-#"
}

helper::GetResult()
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

helper::GetScriptDir()
{
  # Usage GetScriptDir <out:script_dir>
  local out_script_dir=$1
  log::Log "info" "5" "Parameters" "out:script_dir: ${out_script_dir}"

  local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  log::Log "info" "5" "Script Directory" "${script_dir}"
  # eval "${out_script_dir}=$(printf '%q' "${script_dir}")"
  # echo "${out_script_dir}=\"$(printf '%q' "${script_dir}")\""
  # eval "${out_script_dir}=\"$(printf '%q' "${script_dir}")\""

  printf -v "$out_script_dir" '%s' "$script_dir"
}
