defmodule Util do
  @moduledoc """
  Módulo de utilidades para lectura e impresión en consola.
  """

  @doc """
  Muestra un mensaje en consola, lee la entrada del usuario y la retorna como texto.
  Utiliza String.trim/1 para eliminar el salto de línea (\\n) y espacios a los lados.
  """
  def leer(mensaje, :string) do
    mensaje
    |> IO.gets()
    |> String.trim()
  end

  @doc """
  Muestra un mensaje en consola, lee la entrada del usuario y la convierte a entero.
  """
  def leer(mensaje, :integer) do
    mensaje
    |> IO.gets()
    |> String.trim()
    |> String.to_integer()
  end

  @doc """
  Imprime un mensaje final en la terminal.
  """
  def imprimir_mensaje(mensaje) do
    IO.puts(mensaje)
  end
end
