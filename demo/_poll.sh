# Read from stdin
while IFS= read -r id
do
  # Run the command 'foo(ID)'
  curl https://127.0.0.1:8000/gov/members/proposals/"$id"/ballots/$1?api-version=2023-06-01-preview -k -s | jq -r '.error.message' | sed 's/m\[\(.*\)\]/\1/g'
#   echo ""
done