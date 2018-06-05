
doc::ShowMarkdown()
{
  # Usage ShowMarkdown <markdown_file_path>
  local file_path=$1
  pandoc --wrap=preserve "${file_path}" | lynx -dump -stdin
}

doc::Help()
{
  # Usage DisplayHelp <in:file_path>
  local file_path=$1

  log::Log "info" "5" "Markdown File" "${file_path}"
  if [ "${file_path}" == "" ]; then
    doc::ShowMarkdown "../doc/src/index.md"
    return 0
  fi

  if [ -f "${file_path}" ]; then
    doc::ShowMarkdown "${file_path}"
    return 0
  fi

  doc::ShowMarkdown "./_runner.md"
}

