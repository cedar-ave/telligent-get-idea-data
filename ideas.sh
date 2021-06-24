# Prerequisites:
# `chocolatey install jq`
# Add token below
  ## How to get token
     ### Go to avatar (top right) > Settings > API Keys (very bottom) > Manage application API keys > Generate new API key
     ### Base-64 encode `apikey:user.name`.

# Loop through ideas by hundreds
for ((i=0; ; i+=1)); do
    objects=$(curl -H "Rest-User-Token: <YOURTOKEN>" -X GET "https://<YOURINSTANCE>.telligenthosting.net/api.ashx/v2/ideas/ideas.json?PageIndex=$i&PageSize=100")
    echo "$objects" > $i.json
    if jq -e '.Ideas | length == 0' >/dev/null; then 
       break
    fi <<< "$objects"
    jq -r '.Ideas[] | .Challenge.Group.Name + "," + "\"" + .Name + "\"" + "," + .CurrentStatus.Author.DisplayName + "," + .Category.Name + "," + .CurrentStatus.Status.Name + "," + .CreatedDate + "," + (.string + (.TotalVotes|tostring)) + "," + (.string + (.YesVotes|tostring)) + "," + (.string+ (.NoVotes|tostring)) + "," + .Url' <<< "$objects" > $i.json
done

cat *.json > ideas.csv
sed -i 's|,,|,null,|g' ideas.csv

# Header row
sed -i 1i"Group,Title,User,Category,Status,CreatedDate,TotalVotes,YesVotes,NoVotes,URL" ideas.csv
