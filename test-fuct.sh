#!/bin/bash

harvester(){
	[[ ! "$FIGTREE" ]] && echo "I need a fig tree to harvest..." && exit 1

        local _figs=$(<"$FIGTREE" jq '. | keys[]')
        _figs=($(echo "${_figs//\"/}" | tr '\n' ' '))

        for fig in "${_figs[@]}"
	do
		echo -e "\n$fig"
                local _seedpods=$(<"$FIGTREE" jq --arg fig "$fig" '.[$fig] | keys[]')
                _seedpods=($(echo "${_seedpods//\"/}" | tr '\n' ' '))
		for seedpod in "${_seedpods[@]}"
		do
			_seed=$(<"$FIGTREE" jq --arg fig "$fig" --arg seedpod "$seedpod" '.[$fig][$seedpod]')
			seed="${_seed//\"/}"

			[[ ! -z "$seed" ]] && [[ "$seed" != "null" ]] && printf -v "__$seedpod" '%s' "$seed"

			echo "__$seedpod: $(eval echo \${__$seedpod})"
		done
		PROMPT="$__prompt"
		harvest "$fig" "$__verbose" "$__random" "$__min" "$__max"
        done

}

