defmodule Punto3 do
  def main do
    # Reemplaza el 5 por el valor de G elegido por tu grupo
    g = 5
    n_prueba = 10 + g

    IO.puts("--- Traza para n = #{n_prueba} (Sin optimizar) ---")
    es_perfecto = perfecto_traza?(n_prueba)
    IO.puts("¿Es perfecto? #{es_perfecto}")
  end


  # Lógica principal

  def perfecto?(n) when is_integer(n) and n >= 1 do

    limite = n - 1
    suma_divisores(n, 1, limite, 0) == n
  end
  def perfecto?(_), do: {:error, "Entrada inválida"}

  # Caso base de recursión de cola
  defp suma_divisores(_n, actual, limite, acumulador) when actual > limite do
    acumulador
  end

  # Caso recursivo de cola
  defp suma_divisores(n, actual, limite, acumulador) do
    nuevo_acumulador = if rem(n, actual) == 0, do: acumulador + actual, else: acumulador

    # LA ÚLTIMA OPERACIÓN ES LA LLAMADA RECURSIVA
    suma_divisores(n, actual + 1, limite, nuevo_acumulador)
  end


  # Lógica para la traza (con parámetro nivel)
    def perfecto_traza?(n) when is_integer(n) and n >= 1 do
    # Llama a la traza con el límite original n - 1
    suma_divisores_traza(n, 1, n - 1, 0, 0) == n
  end

  defp suma_divisores_traza(_n, actual, limite, acumulador, nivel) when actual > limite do
    IO.puts(String.duplicate("  ", nivel) <> "suma_divisores(actual: #{actual} > limite: #{limite}) -> retorna acumulador: #{acumulador}")
    acumulador
  end

  defp suma_divisores_traza(n, actual, limite, acumulador, nivel) do
    IO.puts(String.duplicate("  ", nivel) <> "suma_divisores(n: #{n}, actual: #{actual}, limite: #{limite}, acc: #{acumulador})")
    nuevo_acumulador = if rem(n, actual) == 0, do: acumulador + actual, else: acumulador
    suma_divisores_traza(n, actual + 1, limite, nuevo_acumulador, nivel + 1)
  end
end

Punto3.main()
