  while : ; do
    BRANCHES_JSON=$(curl --silent --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_HOST/api/v4/projects/$PROJECT_ID/repository/branches?per_page=$PER_PAGE&page=$PAGE")
    if [[ "x$BRANCHES_JSON" == "x[]" ]]; then break; fi
    echo "$BRANCHES_JSON" | jq -r '.[] | .name'
    ((PAGE++))
  done
