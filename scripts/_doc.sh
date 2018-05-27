
doc::ShowMarkdown()
{
  # Usage ShowMarkdown <markdown_file_path>
  local file_path=$1
  pandoc "${file_path}" | lynx -dump -stdin
}
