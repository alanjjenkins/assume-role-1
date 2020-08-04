aws_unset() {
  if [ $(date +%s) -ge $ASSUME_DURING ]; then
    unset ASSUME_DURING;
    unset AWS_ACCESS_KEY_ID;
    unset AWS_SECRET_ACCESS_KEY;
    unset AWS_SESSION_TOKEN;
    unset AWS_SECURITY_TOKEN;
    unset AWS_MFA_TOKEN;
  fi
}

aws_remove_role() {
  unset ASSUME_DURING;
  unset AWS_ACCESS_KEY_ID;
  unset AWS_SECRET_ACCESS_KEY;
  unset AWS_SESSION_TOKEN;
  unset AWS_SECURITY_TOKEN;
  unset AWS_MFA_TOKEN;
}

aws_assume_role() {
  if [ -z "${_2fa}" ];then
    eval $(command assume-role $@);
  else
    eval $(sudo 2fa ${_2fa} | assume-role $@ 2>&1 | grep -o "export .*")
  fi
  export ASSUME_DURING=$(date -v +1H +%s);
}

awseval() {
  if command -v "awsconsole" &>/dev/null; then
    export AWS_DEFAULT_PROFILE=$@;
    eval $(command awsconsole -e $@);
  else
    eval $(command assume-role $@);
  fi
}

awsconsole() {
  if command -v "awsconsole" &>/dev/null; then
    URL=$(command awsconsole -u $@);
  else
    URL=$(command assume-role -console $@);
  fi

  if [ ! -z "$URL" ]; then
    if echo "$URL" | grep -E '^https:' &> /dev/null; then
      xdg-open "$URL";
    fi
  fi
}
