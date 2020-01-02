#!/bin/bash
# -ex

########################################################################
# SOME STUFF I AM TESTING -- NOT CURRENTLY IN USE OR PART OF ANY ACTION
########################################################################

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

                printf -v "PROMPT" '%s' "$__prompt"
                pluck_fig "$fig" "${__verbose:=0}" "${__random:=false}" "${__min:=''}" "${__max:=''}"
        done

}

figsower() {

	[[ ! "$FIGTREE" ]] && echo "I need a fig tree to sow..." && exit 1

	local _cfug="$1"

	[[ ! -z "$2" ]] && local _vbose="$2" || local _vbose="null"
	[[ ! -z "$3" ]] && local _rdom="$3"  || local _rdome="null"
	[[ ! -z "$4" ]] && local _min="$4"   || local _min="null"
	[[ ! -z "$5" ]] && local _max="$5"   || local _max="null"

	local _figtree="$(cat ${FIGTREE})"
	[[ -z "$_figtree" ]] && local _figroot="{}" \
			     || local _figroot="$_figtree"

	unset _figtree
	_figtree="$( echo ${_figroot} | jq . )"
	_figtree=$( echo ${_figtree} | jq --arg prompt "$PROMPT" --arg FIG "$_cfug" '.[$FIG].prompt=$prompt' )
	_figtree=$( echo ${_figtree} | jq --arg verbose "$_vbose" --arg FIG "$_cfug" '.[$FIG].verbose=$verbose' )
	_figtree=$( echo ${_figtree} | jq --arg random "$_rdom" --arg FIG "$_cfug" '.[$FIG].random=$random' )
	_figtree=$( echo ${_figtree} | jq --arg min "$_min" --arg FIG "$_cfug" '.[$FIG].min=$min' )
	_figtree=$( echo ${_figtree} | jq --arg max "$_max" --arg FIG "$_cfug" '.[$FIG].max=$max' )
	[[ ! -z "$_figtree" ]] && ( echo "$_figtree" | jq . > "$FIGTREE" )

	unset _figtree ; unset _cfug ; unset _prompt ;
	unset _vbose ; unset _rdom ; unset _min ; unset _max ;
}












########### NEVER USED
invert() {   #  BOOLEAN
  local __result="$1"
  if [ "${!__result}" ]; then
    eval unset "$__result"
    #FALSE
  else
    eval "$__result"=1
    #TRUE
  fi
}

arg_constructor() {
  local _1="$1"
  local _2="$2"
  if [ -n "$(eval echo \${$_1[1]})" ] ;
  then
    echo "array"
    local _v1="$(eval echo \${$_1[0]})" && printf -v "${_1}" '%s' "${_v1}"
    local _v2="$(eval echo \${$_1[1]})" && printf -v "${_2}" '%s' "${_v2}"
  else
    echo "string / not array"
    printf -v "${_1}" '%s' "${!_1}" && printf -v "${_2}" '%s' "n"
  fi
}