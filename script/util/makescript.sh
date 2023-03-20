#!/usr/bin/env bash

if [ $# != 1 ]; then
	echo argError: $*
	exit 1
fi

touch $1
chmod u+x $1


{
	echo "#!/usr/bin/env bash";
	echo "set -e"
	echo ""
	echo "# if [ \$# != 1 ]; then"
	echo "# 	echo Error: \$*"
	echo "# 	exit 1"
	echo "# fi"
} >> $1
