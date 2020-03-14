defmodule SingyeongPluginTest do
  import Plug.Conn
  alias Singyeong.Plugin.{Manifest, Payload, RestRoute}
  require Logger

  @behaviour Singyeong.Plugin

  @impl Singyeong.Plugin
  def manifest, do: %Manifest{
    name: "Test plugin",
    description: "A plugin for testing out the plugin API.",
    website: "https://github.com/queer/singyeong",
    events: [
      "TEST",
      "HALT",
      "ERROR",
      "ERROR_WITH_UNDO",
      "ERROR_WITH_UNDO_ERROR",
    ],
    capabilities: [
      :custom_events,
      :rest,
    ],
    native_modules: [SingyeongPluginTest.Native],
    rest_routes: [
      %RestRoute{
        method: :get,
        route: "/test",
        module: __MODULE__,
        function: :test_rest_route
      },
      %RestRoute{
        method: :get,
        route: "/test/:test",
        module: __MODULE__,
        function: :test_rest_param_route
      },
    ],
  }

  @impl Singyeong.Plugin
  def load do
    Logger.info "Loaded test plugin! wowie!"
    {:ok, out} = SingyeongPluginTest.Native.add 1, 2
    Logger.info "Addition result from native code: #{out}"
    {:ok, []}
  end

  @impl Singyeong.Plugin
  def handle_event("TEST", data) do
    Logger.info "Handled test event! Wow!"
    Logger.info "Event data: #{inspect data, pretty: true}"
    {:next, Payload.create_payload("TEST", "some cool test data")}
  end

  @impl Singyeong.Plugin
  def handle_event("HALT", data) do
    Logger.warn "HALTing the test event!!"
    Logger.warn "Halt data: #{inspect data, pretty: true}"
    :halt
  end

  @impl Singyeong.Plugin
  def handle_event("ERROR", data) do
    Logger.error "Raising an error!"
    Logger.error "Error data: #{inspect data, pretty: true}"
    {:error, "Manually requested error"}
  end

  @impl Singyeong.Plugin
  def handle_event("ERROR_WITH_UNDO", _data) do
    {:error, "Manually requested error", "undo state"}
  end

  @impl Singyeong.Plugin
  def handle_event("ERROR_WITH_UNDO_ERROR", _data) do
    {:error, "Manually requested error", "undo state"}
  end

  @impl Singyeong.Plugin
  def undo("ERROR_WITH_UNDO", state) do
    Logger.info "Received undo state: #{state}"
    :ok
  end

  @impl Singyeong.Plugin
  def undo("ERROR_WITH_UNDO_ERROR", state) do
    Logger.info "Received undo state: #{state}"
    {:error, "undo error"}
  end

  def test_rest_route(conn, _params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Henlo world")
  end

  def test_rest_param_route(conn, params) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Henlo param: #{params["test"]}")
  end
end
