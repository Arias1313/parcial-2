defmodule Biblioteca do
  @moduledoc """
  Calcula la multa por devolución tardía de un libro.
  """
  @valor_dia 500
  @tope_multa 20000

  def main do
    # CORRECCIONES: Faltaba el '=', había un espacio en ': string', y se bajó todo a minúsculas
    codigo = Util.leer("Ingrese el código del libro: ", :string)
    dias = Util.leer("Ingrese los días de retraso: ", :integer)
    tipo = Util.leer("Tipo de usuario (estudiante/docente): ", :string)

    procesar(codigo, dias, String.downcase(tipo))
    |> generar_mensaje()
    |> Util.imprimir_mensaje()
  end

  defp procesar(codigo, dias, tipo) do
    # CORRECCIÓN: Se agregó la validación de días no negativos (Inciso 4)
    # y el bloque 'else' para capturar los errores del 'with'
    with {:ok, codigo} <- validar_codigo(codigo),
         {:ok, dias} <- validar_dias(dias),
         {:ok, tipo_usuario} <- convertir_tipo(tipo) do

      multa =
        calcular_multa(dias)
        |> aplicar_descuento(tipo_usuario)

      {:ok, codigo, multa}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  # CORRECCIÓN: Se cambió $==6$ por == y byte_size para strings
  defp validar_codigo(codigo) when byte_size(codigo) == 6, do: {:ok, codigo}
  defp validar_codigo(_), do: {:error, "El código debe tener 6 caracteres"}

  # Nueva validación de días (no pueden ser negativos)
  defp validar_dias(dias) when dias >= 0, do: {:ok, dias}
  defp validar_dias(_), do: {:error, "Los días no pueden ser negativos"}

  # CORRECCIONES: 'estudiante' a :estudiante, y :docente a {:ok, :docente} para que el with haga match
  defp convertir_tipo("estudiante"), do: {:ok, :estudiante}
  defp convertir_tipo("docente"), do: {:ok, :docente}
  defp convertir_tipo(_), do: {:error, "Tipo de usuario no válido"}

  # CORRECCIÓN LÓGICA: El guard > 40 debe ir ANTES que el > 0, sino > 0 captura todo.
  defp calcular_multa(dias) when dias > 40, do: @tope_multa
  defp calcular_multa(dias) when dias > 0, do: dias * @valor_dia
  defp calcular_multa(_), do: 0

  # CORRECCIÓN: Se arregló el error de sintaxis 'multa multa * 0.5' usando trunc() para enteros
  defp aplicar_descuento(multa, :estudiante), do: trunc(multa * 0.5)
  defp aplicar_descuento(multa, :docente), do: multa

  defp generar_mensaje({:ok, codigo, 0}), do: "El libro #{codigo} no tiene multa"
  defp generar_mensaje({:ok, codigo, multa}), do: "El libro #{codigo} tiene una multa de $#{multa}"
  # CORRECCIÓN: Se cerró bien la llave '}' en {:error, motivo}
  defp generar_mensaje({:error, motivo}), do: "Error: #{motivo}"
end

# Ejecuta el programa
Biblioteca.main()
