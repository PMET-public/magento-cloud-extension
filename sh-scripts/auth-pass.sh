msg Enabling password based access ...

${cli_path} httpaccess -p ${project} -e ${environment} --no-wait --auth "admin:${project}"
${cli_path} httpaccess -p ${project} -e ${environment} --no-wait --access ""