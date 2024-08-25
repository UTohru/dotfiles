cdir="$(realpath "$(dirname "$0")")"

if [ -x "$(command -v cdk )" ]; then
	# https://github.com/aws/aws-cdk/discussions/24380
	function _cdk_yargs_completions(){
		local reply
		local si=$IFS
		IFS=$'
'
		reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" cdk --get-yargs-completions "${words[@]}"))
		IFS=$si
		_describe 'values' reply
	}
	compdef _cdk_yargs_completions cdk
fi

if [ -x "$(command -v aws_completer)" ]; then
	function _aws_completions(){
		local reply
		local si=$IFS
		IFS=$'
'
		reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" aws_completer))
		IFS=$si
		_describe 'values' reply
	}
	compdef _aws_completions aws
fi
