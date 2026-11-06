defmodule Punto3Mejora do
  def main do
    # Reemplaza el 5 por el valor de G elegido por tu grupo
    g = 5
    n_prueba = -5 + g

    IO.puts("--- Traza para n = #{n_prueba} ---")
    es_perfecto = perfecto_traza?(n_prueba)
    IO.puts("¿Es perfecto? #{es_perfecto}")

    IO.puts("\n--- Números perfectos menores a 10.000 ---")
    IO.inspect(listar_perfectos(10_000))
  end


  # Lógica principal (Número Perfecto)

  def perfecto?(n) when is_integer(n) and n >= 1 do
    # Optimización: el mayor divisor propio posible es la mitad del número
    limite = div(n, 2)
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

    # LA ÚLTIMA OPERACIÓN ES LA LLAMADA RECURSIVA (Recursión de cola)
    suma_divisores(n, actual + 1, limite, nuevo_acumulador)
  end


  # Lógica para la traza (con parámetro nivel)

  def perfecto_traza?(n) when is_integer(n) and n >= 1 do
    suma_divisores_traza(n, 1, div(n, 2), 0, 0) == n
  end
  def perfecto_traza?(_), do: {:error, "Entrada inválida"}

  defp suma_divisores_traza(_n, actual, limite, acumulador, nivel) when actual > limite do
    IO.puts(String.duplicate("  ", nivel) <> "suma_divisores(actual: #{actual} > limite: #{limite}) -> retorna acumulador: #{acumulador}")
    acumulador
  end

  defp suma_divisores_traza(n, actual, limite, acumulador, nivel) do
    IO.puts(String.duplicate("  ", nivel) <> "suma_divisores(n: #{n}, actual: #{actual}, limite: #{limite}, acc: #{acumulador})")
    nuevo_acumulador = if rem(n, actual) == 0, do: acumulador + actual, else: acumulador
    suma_divisores_traza(n, actual + 1, limite, nuevo_acumulador, nivel + 1)
  end


  # Segunda función: Listar perfectos < 10.000

  def listar_perfectos(limite) do
    buscar_perfectos(1, limite, [])
  end

  defp buscar_perfectos(actual, limite, encontrados) when actual >= limite do
    # Invertimos la lista al final porque agregamos elementos a la cabeza (más eficiente)
    Enum.reverse(encontrados)
  end

  defp buscar_perfectos(actual, limite, encontrados) do
    nuevos_encontrados = if perfecto?(actual), do: [actual | encontrados], else: encontrados
    buscar_perfectos(actual + 1, limite, nuevos_encontrados)
  end
end

Punto3Mejora.main()
