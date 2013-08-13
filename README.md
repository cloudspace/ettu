Ettu
====

[![Build Status](https://travis-ci.org/cloudspace/ettu.png?branch=v3)](https://travis-ci.org/cloudspace/ettu)

Using Rails 3's `stale?` or `fresh_when`? Are your users seeing old view
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

Installation
------------

Add Ettu and [cache_digests](https://github.com/rails/cache_digests) to
your Gemfile:

    gem 'ettu', '~> 3.0'

And `$ bundle install`

Usage
-----

Rails ETags can be used in the following way:

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
view code. By default, it will add in the fingerprints of your
precompiled assets along with the cache digest of the current action
into the calculation for the final ETag sent to the browser.

### Configuring

Ettu can be disabled for any environment using the `ettu.disabled`
config option.

```ruby
# config/environments/*.rb
My::Application.configure do
  config.ettu.disabled = true
end
```

Of course, you can override Ettu's default behavior:

```ruby
# config/initializers/ettu.rb
Ettu.configure do |config|
  # Add in extra assets to account for
  config.assets += ['first.js', 'second.css']
end
```

Or each can be passed on an individual basis:

    fresh_when @product, assets: 'super.css'

Additionally, you can specify a different template to calculate with the
`view` option:

    fresh_when @product, view: 'products/index'

You can even stop Ettu from accounting for any of them by setting the
value to `false`:

    fresh_when @product, assets: false, view: false

### What about Rails' default `fresh_when`?

Ettu tries its darndest to not interfere with Rails' default
implementation. Ettu makes sure to pass all the options you specify to
Rails (like the `public` option). It's even coded as a drop-in gem that
won't cause problems if it's not installed.

RAILS_ENV=development Issues
----------------------------

In order for Ettu to detect changes to templates in the **development**
environment, you must disable `cache_template_loading`.

```ruby
# config/environments/development.rb
My::Application.configure do
  config.action_view.cache_template_loading = false
end
```

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Code your feature, and add specs for it
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
