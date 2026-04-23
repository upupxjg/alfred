#!/bin/zsh

set -u

query="${1-}"
query="$(printf '%s' "$query" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

json_escape() {
  local value="$1"
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/\\r}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

print_item() {
  local title subtitle arg
  title="$(json_escape "$1")"
  subtitle="$(json_escape "$2")"
  arg="$(json_escape "$3")"
  printf '{"title":"%s","subtitle":"%s","arg":"%s"}' "$title" "$subtitle" "$arg"
}

now_ms() {
  perl -MTime::HiRes=time -e 'printf("%.0f\n", time() * 1000)'
}

floor_div_1000() {
  local n="$1"
  if (( n >= 0 )); then
    printf '%s\n' $(( n / 1000 ))
  else
    printf '%s\n' $(( - (( -n + 999 ) / 1000 ) ))
  fi
}

format_epoch() {
  date -r "$1" "+%Y-%m-%d %H:%M:%S" 2>/dev/null
}

format_epoch_ms() {
  local epoch_ms="$1"
  local epoch_sec ms_part base
  epoch_sec="$(floor_div_1000 "$epoch_ms")"
  ms_part=$(( epoch_ms - epoch_sec * 1000 ))
  base="$(format_epoch "$epoch_sec")" || return 1
  printf '%s.%03d\n' "$base" "$ms_part"
}

parse_datetime() {
  local input="$1"
  local normalized="${input/T/ }"
  local epoch

  epoch="$(date -j -f "%Y-%m-%d %H:%M:%S" "$normalized" "+%s" 2>/dev/null)" || return 1
  printf '%s\n' "$epoch"
}

emit_items() {
  local formatted="$1"
  local epoch_sec="$2"
  local epoch_ms="$3"
  printf '{"items":['
  print_item "$formatted" "格式化时间，回车复制" "$formatted"
  printf ','
  print_item "$epoch_sec" "秒级时间戳，回车复制" "$epoch_sec"
  printf ','
  print_item "$epoch_ms" "毫秒级时间戳，回车复制" "$epoch_ms"
  printf ']}\n'
}

emit_items_with_ms_datetime() {
  local formatted_sec="$1"
  local formatted_ms="$2"
  local epoch_sec="$3"
  local epoch_ms="$4"
  printf '{"items":['
  print_item "$formatted_sec" "秒级格式化时间，回车复制" "$formatted_sec"
  printf ','
  print_item "$formatted_ms" "毫秒级格式化时间，回车复制" "$formatted_ms"
  printf ','
  print_item "$epoch_sec" "秒级时间戳，回车复制" "$epoch_sec"
  printf ','
  print_item "$epoch_ms" "毫秒级时间戳，回车复制" "$epoch_ms"
  printf ']}\n'
}

if [[ -z "$query" ]]; then
  current_ms="$(now_ms)"
  printf '{"items":['
  print_item "$current_ms" "当前时间（毫秒时间戳），回车复制" "$current_ms"
  printf ']}\n'
  exit 0
fi

if [[ "$query" =~ ^-?[0-9]+$ ]]; then
  abs_query="${query#-}"

  if (( abs_query >= 1000000000000 )); then
    epoch_ms="$query"
    epoch_sec="$(floor_div_1000 "$query")"
    formatted_sec="$(format_epoch "$epoch_sec")"
    formatted_ms="$(format_epoch_ms "$epoch_ms")"
    if [[ -n "$formatted_sec" && -n "$formatted_ms" ]]; then
      emit_items_with_ms_datetime "$formatted_sec" "$formatted_ms" "$epoch_sec" "$epoch_ms"
      exit 0
    fi
  else
    epoch_sec="$query"
    epoch_ms=$(( query * 1000 ))
    formatted="$(format_epoch "$epoch_sec")"
    if [[ -n "$formatted" ]]; then
      emit_items "$formatted" "$epoch_sec" "$epoch_ms"
      exit 0
    fi
  fi
fi

epoch_sec="$(parse_datetime "$query")"
if [[ -n "${epoch_sec:-}" ]]; then
  epoch_ms=$(( epoch_sec * 1000 ))
  formatted="$(format_epoch "$epoch_sec")"
  emit_items "$formatted" "$epoch_sec" "$epoch_ms"
  exit 0
fi

printf '{"items":['
print_item "无法解析输入" "支持 yyyy-MM-dd HH:mm:ss，或秒/毫秒时间戳" "$query"
printf ']}\n'
