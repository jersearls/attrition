defmodule Attrition do
  @moduledoc """
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
  """

  @callback data_qa(value :: any()) :: String.t() | {:safe, String.t()}
  @callback data_test(value :: any()) :: String.t() | {:safe, String.t()}

  @data_module Application.get_env(:attrition, :data_module, Attrition.Hide)

  @doc """
  Injects a function definition based on the mix env
  configuration module that is passed.
  No arguments are given.

  The macro defines helper functions once at
  compile-time rather than checking for configuration
  with each function call.

  The functions generated are overrideable.
  """
  @spec __using__([]) :: Macro.t()
  defmacro __using__([]) do
    quote do
      @behaviour Attrition

      @impl Attrition
      def data_qa(value) do
        Attrition.data_module().data_qa(value)
      end

      @impl Attrition
      def data_test(value) do
        Attrition.data_module().data_test(value)
      end

      defoverridable Attrition
    end
  end

  @spec data_module :: atom()
  def data_module, do: @data_module

  defmodule Reveal do
    @moduledoc """
    `Attrition.Reveal` returns the "real" versions of data functions,
    revealing the passed value contents to your markup.

    This module is for configured environments only.
    """

    @type safe_string :: {:safe, String.t()}

    @doc """
    Returns :safe HTML string that has interior quotes of interpolated
    string escaped with prepended whitespace padding.
    """
    @spec data_qa(String.t()) :: safe_string()
    def data_qa(string) when is_binary(string), do: {:safe, ~s( data-qa="#{string}")}

    @doc """
    Returns :safe HTML string that has interior quotes of interpolated
    string escaped with prepended whitespace padding.
    """
    @spec data_test(String.t()) :: safe_string()
    def data_test(string) when is_binary(string), do: {:safe, ~s( data-test="#{string}")}
  end

  defmodule Hide do
    @moduledoc """
    `Attrition.Hide` returns the noop versions of data functions, essentially
    "hiding" them by returning an empty string into markup.

    This is the default module for unconfigured or miconfigured
    environments; preventing sensitive data from leaking into production
    inadvertantly.
    """

    @doc """
    Returns empty string regardless of argument.
    """
    @spec data_qa(any()) :: String.t()
    def data_qa(_), do: ""

    @doc """
    Returns empty string regardless of argument.
    """
    @spec data_test(any()) :: String.t()
    def data_test(_), do: ""
  end
end
