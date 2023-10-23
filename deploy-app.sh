workspace=("web-app")
mainBranch="master"
productionBranch="production"
watchedArr=("deploy-app.sh" "mobile-app/" "functions/")
changesArr=()

# check working directory is clean
if [ -z "$(git status --porcelain)" ]; then
  echo "Working directory is clean... 👍"
else
  >&2 echo "Working directory must be clean. Stash or commit changes."
  exit 1
fi

# get user confirmation
read -p "Are you sure you want to deploy to $productionBranch? (y/N): " confirm;
if [[ $confirm != [yY] ]] && [[ $confirm != [yY][eE][sS] ]]; then
  >&2 echo "Exiting... "
  exit 1
fi
echo "Deploying new production version..."

# DEPLOY TO PRODUCTION
# switch to $productionBranch branch and merge changes
git checkout $productionBranch
git merge $mainBranch --no-commit

# check for changes to $watched
for watched in ${watchedArr[@]}
do
  if [[ ! -z "$(git status -- $watched | grep $watched)" ]]; then changesArr+=(true);
  else changesArr+=(false); fi
done

# commit merge
git commit -am "Merge branch '$mainBranch' into $productionBranch"

# build, commit and push changes
npm run build
git commit -am "build"
git push

# switch back to $mainBranch branch
git checkout $mainBranch

# print out useful links and messages
echo "\n\n"
for index in ${!changesArr[@]}
do
  if [ ${changesArr[$index]} == true ]; then echo "✅ Changes made to '"${watchedArr[index]}"'";
  else echo "❌ No changes made to '"${watchedArr[index]}"'"; fi
done