[![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg)](https://hexdocs.pm/attrition)

# Attrition

> An Elixir Testing and QA helper for use with the Phoenix framework.

Attrition provides the ability to display specific data HTML attributes
based on the configuration of your mix environment.

For example, testing and QA can be performed using the `data-qa` or `data-test` attribute,
while these attributes are effectively removed from your production markup.
Attrition accomplishes this through the use of a compile time macro that injects
overrideable functions.

If correctly configured and enabled, Attrition provided functions return
HTML attributes that can be utilized for testing, QA and beyond.

If no cofiguration is present, Attrition provided functions simply return
an empty string, thus obfuscating their contents in non-configured envrionments.

The intentional default redaction of test data and attributes reduces the risk
of scraping or accidentally exposing sensitive data.

Currently Attrition only supports the `data-qa` and `data-test`
HTML attributes.

> develop |> attrition |> deploy

## Installation

Attrition can be installed by adding `attrition` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:attrition, "~> 0.1.0"}
  ]
end
```

### Fetch the dependencies

```shell
mix deps.get
```

## Setup
Setup for attrition can be accomplished in two easy steps!

### 1. Environment Configuration

In the configuration file for the environment you wish to render the
data attributes, you must set the `Attrition.Reveal` module as the
value for the `:data_module` key.

For example:

```elixir
# dev.exs or test.exs
config :attrition, data_module: Attrition.Reveal
```

**Note** After updating your configuration, you must force the Attrition
dependency to recompile in order to pick up on the configuration change.

```shell
mix deps.compile attrition --force
```

The absence of a configuration, or an invalid configuration will
result in no data attributes displayed.

### 2. `Use` Attrition

Ideally, Attrition is invoked at the view definition through
the `use` macro. This allows for Attrition provided functions
to be called in both the view and template without needing to
provide an alias. This implementation provides a simple,
light-weight interface without additional cognitive load.

```elixir
# application_web.ex

  def view do
    quote do
      ...

      use Attrition
    end
  end
```

## Usage

Once setup and configuration is complete, using Attrition
provided functions is very straightforward. These functions
can be invoked at both the view and template. All attrition provided
functions can also be overridden wherever they are used.

Example implementation of the `data_qa` function:
```elixir
  <div<%= data_qa "example-count" %> class="example">
```

**NOTE**: In the example above, make note of the spacing. Ensure that
there is not a space between the element `<div` and the opening output capture
tag `<%=`. This will ensure the resulting html is formatted correctly.

Example enabled attribute output:
```html
<div data-qa="example-count" class="example">
```

Hidden attribute output:
```html
<div class="example">
```

## Testing and Developing with data attributes
### Find the data-qa attribute value using Floki
[Floki](https://hex.pm/packages/floki) is a simple HTML parser that
can quickly traverse HTML nodes. You can read more about Floki
[here](https://hexdocs.pm/floki/Floki.html).

Finding your data-qa attribute with Floki example
```elixir
{:ok, html} = Floki.parse_document(html)

Floki.find(html, "[data-qa=example-count]")
```

### View data-qa elements in the Browser
Using a browser extension, such as [data-qa Highlighter](https://chrome.google.com/webstore/detail/data-qa-highlighter/idhhdaefanknhldagkhodblcpifdddcf?hl=en)
you can easily view the elements on the page that have the data-qa attribute.

![Sample data-qa highlighting](https://lh3.googleusercontent.com/EEJotHEtiJT8VtbXYfb1_kDMOruvRQzsc4fk8kP93AHQnWlweht8OfJ4M8sIgxLEyxZhZ7dmVwU=w640-h400-e365)
