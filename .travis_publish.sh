if [ "$TRAVIS_BRANCH$TRAVIS_PULL_REQUEST" == "masterfalse" ] ; then
  cd _site
  git init
  git checkout -b gh-pages
  git config --global user.email "jamespjh@gmail.com"
  git config --global user.name "Pushed by Travis CI"
  git add .
  git commit -m "Pushed by Travis"
  openssl aes-256-cbc -K $encrypted_074e99c4de0f_key -iv $encrypted_074e99c4de0f_iv \
    -in deploy_key.enc -out deploy_key -d
  REPO=`git config remote.origin.url`
  SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}
  eval `ssh-agent -s`
  chmod 600 deploy_key
  ssh-add deploy_key
  echo $SSH_REPO
  git remote add origin git@github.com:UCL-RITS/research-computing-with-cpp
  echo $TRAVIS_BRANCH $TRAVIS_PULL_REQUEST
  git push -f -u origin gh-pages
fi

