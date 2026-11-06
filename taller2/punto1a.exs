defmodule Punto1A do
  @vocales ["a", "e", "i", "o", "u", "A", "E", "I", "O", "U",
            "á", "é", "í", "ó", "ú", "Á", "É", "Í", "Ó", "Ú", "ü", "Ü"]


  def main do
    IO.puts("--- Traza para Juan Sánchez ---")
    resultado = contar("Juan Sánchez")
    IO.puts("Total de vocales: #{resultado}")
  end

  def contar(cadena) when is_binary(cadena) do
    contar_recursivo(String.graphemes(cadena), 0)
  end
  def contar(_), do: {:error, "La entrada no es una cadena"}

  defp contar_recursivo([], nivel) do
    IO.puts(String.duplicate("  ", nivel) <> "contar_recursivo([]) -> 0")
    0
  end

  defp contar_recursivo([cabeza | cola], nivel) do
    IO.puts(String.duplicate("  ", nivel) <> "contar_recursivo([#{inspect(cabeza)} | cola])")

    es_vocal = if cabeza in @vocales, do: 1, else: 0
    resultado = es_vocal + contar_recursivo(cola, nivel + 1)

    IO.puts(String.duplicate("  ", nivel) <> "Retorno: #{resultado}")
    resultado
  end
end

Punto1A.main()
