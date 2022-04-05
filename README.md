# ep_export_static_html

Generate static html website from `etherpad-lite` pad content.

## Requirements

- running `nginx` and `etherpad-lite` processes

## Usage

``` sh
git clone https://github.com/alx/ep_export_static_html.git
cd ep_export_static_html
vim export.sh # set ROOT_PAD from where the content would be fetched
./export.sh
```

Static html content can now be served from `./static/` folder.

``` sh
cd ./static/
python3 -m http.server
# content now accessible on http://localhost:8080
```

## Templates

`header`, `body` and `footer` templates can be modified in the html files avilable in `./templates/` folder.
