
# Using jq regex so we can support groups
applyRegex_version() {
  local regex=$1
  local file=$2

  jq -n "{
  version: $(echo $file | jq -R .)
  }" | jq --arg v "$regex" '.version | capture($v)' | jq -r '.version'

}

# retrieve current from artifactory
# e.g url=http://your-host-goes-here:8081/artifactory/api/storage/your-path-goes-here
#     regex=ecd-front-(?<version>.*).tar.gz
artifactory_current_version() {
  local artifacts_url=$1?list'&'deep=1
  local regex=$2
  local sortByDate="$3"

  curl $artifacts_url | jq --arg v "$regex" --arg sortBy "$(sort_by $sortByDate)" "[.files[] | . + (.uri | capture(\$v)) ] | sort_by($(sort_by $sortByDate))" | jq '[.[length-1] | {version: .version}]'
}

# Return all versions
artifactory_versions() {
  local artifacts_url=$1?list'&'deep=1
  local 
  regex=$2
  local sortByDate="$3"


  curl $artifacts_url | jq --arg v "$regex" --arg sortBy "$(sort_by $sortByDate)" "[.files[] | . + (.uri | capture(\$v)) ] | sort_by($(sort_by $sortByDate))" | jq '[.[] | {version: .version}]'

}

sort_by() {
  if [[ "$1" == "true" ]]
  then
    echo ".lastModified"
  else
    echo ".version"
  fi
}

# return uri and version of all files
artifactory_files() {
  local artifacts_url=$1?list'&'deep=1
  local regex="$2"
  local sortByDate="$3"

  curl $artifacts_url | jq --arg v "$regex" "[.files[] | . + (.uri | capture(\$v)) ] | sort_by($(sort_by $sortByDate))"

}

in_file_with_version() {
  local artifacts_url=$1
  local regex="$2"
  local version=$3
  local sortByDate=$4

  result=$(artifactory_files "$artifacts_url" "$regex" "$sortByDate")
  echo $result | jq --arg v "$version" '[foreach .[] as $item ([]; $item ; if $item.version == $v then $item else empty end)]'

}


# return the list of versions from provided version
check_version() {
  local artifacts_url=$1
  local regex=$2
  local version=$3

  result=$(artifactory_versions "$artifacts_url" "$regex")  #result=$(curl "$artifacts_url" "$regex")
  echo $result | jq --arg v "$version" '[foreach .[] as $item ([]; $item ; if $item.version >= $v then $item else empty end)]'

}
