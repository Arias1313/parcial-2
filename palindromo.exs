defmodule Palindroma do

  def main do
    leer_cadena("Ingrese una cadena: ")
    |> es_palindroma?()
    |> generar_mensaje()
    |> imprimir()
  end

  defp es_palindroma?(cadena_texto) do
    cadena_minuscula = String.downcase(cadena_texto) # Convierte a minúsculas toda la cadena
    cadena_sin_espacios = String.replace(cadena_minuscula, " ", "") # Elimina espacios en blanco
    String.reverse(cadena_sin_espacios) == cadena_sin_espacios # Compara la cadena original con la invertida, retorna true o false
  end

  defp imprimir(mensaje) do
    IO.puts(mensaje)
  end

  defp leer_cadena(texto) do
    IO.gets(texto)
    |> String.trim()
  end

  defp generar_mensaje(es_palindroma) do
    if es_palindroma do
      "La cadena es palíndroma"
    else
      "La cadena no es palíndroma"
    end
  end

end

Palindroma.main() # Invoca la función principal para ejecutar el programa
