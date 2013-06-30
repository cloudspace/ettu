# Ettu

Using Rails 4's `stale?` or `fresh_when`? Are your users seeing old view
code even after new deploys? The Rails way `fresh_when(@product)`
doesn't account for changes in your view code, you have to do it
yourself.

Ettu (loosely translated "And calculate you, too?") transparently
accounts for the current action's view code (JavaScript, CSS, templates)
using the same [asset fingerprinting]
(http://guides.rubyonrails.org/asset_pipeline.html#what-is-fingerprinting-and-why-should-i-care-questionmark)
and Russian Doll [template cache digesting]
(https://github.com/rails/cache_digests#readme) used by Rails. It does
all of this while allowing you to use the same syntax you're already
accustomed to. So keep doing what you're doing, and let Ettu worry about
changes to your view code.

## Installation

Add this line to your application's Gemfile:

    gem 'ettu'

And then execute:

    $ bundle

And that's it. Ettu will be loaded on your next restart.

## Usage

Rails 4 ETags can be used in the following way:

```ruby
class ProductsController < ApplicationController
    def show
        @product = Product.find(params[:id])

        # Sugar syntax
        fresh_when @product

        # Hash syntax
        fresh_when etag: @product, last_modified: @product.updated_at, public: true
    end
end
```

Ettu wants you to keep using either syntax, and let it worry about the
view code. By default, it will add in the asset fingerprints of
`application.js` and `application.css` along with the cache digest of
the current action into the calculation for the final ETag sent to the
browser.

### Configuring

Of course, you can override Ettu's behavior. Using a custom js file?
Just pass in like so:

    fresh_when @product, js: 'custom.js'

The same things goes for custom css files:

    fresh_when @product, css: 'custom.css'

Have several other assets you want to account for? Pass them in as an
array with the `assets` key:

    fresh_when @product, assets: ['first.css', 'second.js']

You can specify a template with the `view` key:

    fresh_when @product, "products/index"

You can even stop Ettu from accounting for any of them by setting the
value to `false`:

    fresh_when @product, js: false, css: false, view: false

### What about Rails' default `fresh_when`?

Ettu tries its darndest to not interfere with Rails' default
implementation. Ettu makes sure to pass all the options you specify to
Rails (like the `public` option). It's even coded as a drop-in gem that
won't cause problems if it's not installed.

## RAILS_ENV=development Issues

Until [rails/rails#10791](https://github.com/rails/rails/pull/10791)
gets merged in, Ettu will not be able to detect changes in templates
while in the **development** environment. This is not an issue that
affects staging or production, because the template cache will be
recreated after each deploy.

In the mean time, you can monkey-patch around this:

```ruby
# config/environments/development.rb
class BlackHole < Hash
    def []=(k, v); end
end
module ActionView
  class Digestor
    @@cache = BlackHole.new
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Code your feature, and add specs for it
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
