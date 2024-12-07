.PHONY: serve build clean setup

serve:
	bundle exec jekyll serve --livereload

build:
	bundle exec jekyll build

clean:
	bundle exec jekyll clean
	rm -rf _site .jekyll-cache

setup:
	which ruby || brew install ruby
	# Need global jekyll only to setup, so don't install with brew
	bundle config --local path .bundle
	bundle install
	bundle update
