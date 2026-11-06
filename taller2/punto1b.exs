defmodule Punto1B do
  def main do
    IO.puts("--- Traza para Juan Sánchez ---")
    resultado = contar("Juan Sánchez")
    IO.puts("Total de vocales: #{resultado}")
  end

  def contar(cadena) when is_binary(cadena) do
    contar_recursivo(cadena, 0)
  end
  def contar(_), do: {:error, "La entrada no es una cadena"}

  # Caso base: cadena vacía
  defp contar_recursivo("", nivel) do
    IO.puts(String.duplicate("  ", nivel) <> "contar_recursivo(\"\") -> 0")
    0
  end

  # Caso recursivo: pattern matching sobre binarios
  defp contar_recursivo(<<cabeza::utf8, cola::binary>>, nivel) do
    # Imprimimos la cabeza reconvirtiéndola a binario para que sea legible en consola
    char_str = <<cabeza::utf8>>
    IO.puts(String.duplicate("  ", nivel) <> "contar_recursivo(<<#{inspect(char_str)}::utf8, cola::binary>>)")

    es_vocal = if es_vocal?(cabeza), do: 1, else: 0
    resultado = es_vocal + contar_recursivo(cola, nivel + 1)

    IO.puts(String.duplicate("  ", nivel) <> "Retorno: #{resultado}")
    resultado
  end

  # Función auxiliar para identificar vocales comprobando los codepoints numéricos enteros
  defp es_vocal?(char) when char in [
    ?a, ?e, ?i, ?o, ?u, ?A, ?E, ?I, ?O, ?U,
    ?á, ?é, ?í, ?ó, ?ú, ?Á, ?É, ?Í, ?Ó, ?Ú, ?ü, ?Ü
  ], do: true
  defp es_vocal?(_), do: false
end

# Ejecución al final del archivo
Punto1B.main()
