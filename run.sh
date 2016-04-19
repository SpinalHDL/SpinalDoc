echo "updating urls.yml"
cd _site
mv urls.txt ../_data/urls.yml
cd ../
echo "serving jekyll"
bundle exec jekyll serve
