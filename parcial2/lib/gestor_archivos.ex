defmodule GestorArchivos do
  def stream_lineas_limpias(ruta) do
    if File.exists?(ruta) do
      stream =
        File.stream!(ruta)
        |> Stream.map(&String.trim/1)
        |> Stream.reject(fn linea -> linea == "" or String.starts_with?(linea, "#") end)

      {:ok, stream}
    else
      {:error, "El archivo '#{ruta}' no existe."}
    end
  end

  def escribir_lineas(ruta, stream_o_lista) do
    archivo = File.open!(ruta, [:write, :utf8])

    stream_o_lista
    |> Stream.each(fn linea -> IO.puts(archivo, linea) end)
    |> Stream.run()

    File.close(archivo)
  end
end
