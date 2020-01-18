defmodule SingyeongPluginTest do
  alias Singyeong.Plugin.{Manifest, Payload}
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
    ]
  }

  @impl Singyeong.Plugin
  def load do
    Logger.info "Loaded test plugin! wowie!"
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
end
