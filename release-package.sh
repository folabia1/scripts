mainBranch="master"
releaseBranch="release"
prereleaseBranch="prerelease"
packageName="package_name" # TODO: replace
username="username" # TODO: replace
repositoryName="repo_name" # TODO: replace

# check working directory is clean
if [ -z "$(git status --porcelain)" ]; then 
  echo "Working directory is clean... 👍"
else 
  >&2 echo "Working directory must be clean. Stash or commit changes."
  exit 1
fi

# check valid version selected
if [[ $# -eq 0 ]] || [[ $1 == "prerelease" ]]; then 
  versionType="prerelease";
  echo "Releasing new prerelease version..."
else
  if [[ $1 == "patch" ]] || [[ $1 == "minor" ]] || [[ $1 == "patch" ]]; then 
    read -p "Are you sure you want to release a new $1 version? (y/N): " confirm;
    if [[ $confirm != [yY] ]] && [[ $confirm != [yY][eE][sS] ]]; then
      >&2 echo "Exiting... "
      exit 1
    fi
    versionType=$1;
    echo "Releasing new $1 version..."
  else
    >&2 echo "Invalid version provided. Must be 'prerelease' (default), 'patch', 'minor' or 'major"
    exit 1
  fi
fi

if [[ $versionType != "prerelease" ]]; then
  # PUBLISH ON RELEASE BRANCH
  # switch to release branch
  git checkout release

  # merge and build changes
  git merge $mainBranch -m "Merge branch '$mainBranch' into release"
  npm run build
  git commit -am "build package"

  # release new version
  oldPackageVersion=$(node -p "require('./package.json').version")
  npm version $versionType
  newPackageVersion=$(node -p "require('./package.json').version")
  git push
fi

# ALWAYS PUBLISH ON PRERELEASE BRANCH
# switch to $prereleaseBranch
git checkout $prereleaseBranch

# merge and build changes
git merge $mainBranch -m "Merge branch '$mainBranch' into release"
npm run build
git commit -am "build package"

# release new version
if [[ $versionType == "prerelease" ]]; then
  oldPackageVersion=$(node -p "require('./package.json').version")
  npm version prerelease
  newPackageVersion=$(node -p "require('./package.json').version")
else
  npm version "$newPackageVersion-0"
fi
git push

# switch back to $mainBranch
git checkout $mainBranch

comparisonUrl="https://github.com/$username/$repositoryName/compare/v$oldPackageVersion...v$newPackageVersion"
pipelineUrl="https://github.com/$username/$repositoryName/actions/workflows"
changelogUrl="https://github.com/$username/$repositoryName/blob/$mainBranch/CHANGELOG.md"

# update changelog
if [[ $versionType != "prerelease" ]]; then
  echo "# v$newPackageVersion\n\n[View changelog]($comparisonUrl)\n\n$(cat CHANGELOG.md)" > CHANGELOG.md
  git commit -am "update changelog"
  git push
fi

# print out useful links and messages
echo "\nPipeline: $pipelineUrl\n\n\n\n"
if [[ $versionType == "prerelease" ]]; then
  echo "New PRERELEASE version of $packageName (v$newPackageVersion) available to install"
  echo "\`\`\`\nnpm install $packageName@prerelease\n\`\`\`"
  echo "View v$newPackageVersion changes: $comparisonUrl)"
else
  echo "New version of $packageName (v$newPackageVersion) available to install"
  echo "\`\`\`\nnpm install $packageName@latest\n\`\`\`"
  echo "You can find the changes [here]($changelogUrl)"
fi
