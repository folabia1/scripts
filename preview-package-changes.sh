mainBranch="master"
releaseBrach="release"
packageName="package_name" # TODO: replace
username="username"
repositoryName="repo_name"

comparisonUrl="https://github.com/$username/$repositoryName/compare/$releaseBrach...$mainBranch"

echo "Preparing to release a new $packageName verion."
echo "Here are all the changes since the last release: $comparisonUrl"
echo "\nHere's a quick summary of the most relevant file changes"
echo "Please feel free to leave feedback/concerns before it's released, will be releasing soon."
echo "\n$(git diff $mainBranch $releaseBrach --compact-summary | grep "src")"

