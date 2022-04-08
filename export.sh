#!/bin/bash

cd /opt/etherpad/export_static/

ROOT_PAD="home"
EXPORT_PATH="./static/"

ETHERPAD_URL="http://localhost:9001/p/"
ETHERPAD_EXPORT_PATH="/export/html"

PROCESSED_PADS=()

parse_url () {

    SOURCE_NAME=$1
    OUTPUT_NAME=${2:-"${SOURCE_NAME}"}

    if [[ ${PROCESSED_PADS[*]} =~ $SOURCE_NAME ]]; then
        return 1
    else
        PROCESSED_PADS+=($SOURCE_NAME)

        SOURCE="${ETHERPAD_URL}${SOURCE_NAME}${ETHERPAD_EXPORT_PATH}"
        OUTPUT_FILE="${EXPORT_PATH}${OUTPUT_NAME}.html"

        curl -o $OUTPUT_FILE $SOURCE

        # include html content
        sed -i -e 's/<head>/cat templates\/header.html/e' $OUTPUT_FILE
        sed -i -e 's/<body>/cat templates\/body.html/e' $OUTPUT_FILE
        sed -i -e 's/<\/body>/cat templates\/footer.html/e' $OUTPUT_FILE

        # fetch internal links list
        INTERNAL_LINKS=( $(cat $OUTPUT_FILE | grep -Pio "\[\[.*?\]\]")  )

        # format internal links
        sed -r -i -e 's/\[\[(.*?)\]\]/<a href="\1.html">\1<\/a>/g' $OUTPUT_FILE

        for INTERNAL_PAD in "${INTERNAL_LINKS[@]}"
        do
            PAD_NAME=${INTERNAL_PAD//[\[|\]]/}
            echo $PAD_NAME
            parse_url $PAD_NAME
        done
    fi

}

parse_url $ROOT_PAD index
