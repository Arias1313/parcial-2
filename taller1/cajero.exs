defmodule Cajero do
  @moduledoc """
  Simula un retiro en cajero automático aplicando validaciones secuenciales.
  """
  @pin_correcto "0482"
  @saldo_disponible 450_000
  @limite_por_retiro 600_000

  def main do
    pin = Util.leer("Ingrese su PIN de 4 dígitos: ", :string)
    cuenta = Util.leer("Tipo de cuenta (ahorros o corriente): ", :string)
    monto = Util.leer("Monto a retirar (Múltiplo de 10.000): ", :integer)

    retirar(pin, cuenta, monto)
  end

  def retirar(pin_input, cuenta_input, monto) do
    with :ok <- validar_pin(pin_input),
         {:ok, tipo_cuenta} <- validar_cuenta(String.downcase(cuenta_input)),
         :ok <- validar_monto_positivo(monto),
         :ok <- validar_multiplo(monto),
         :ok <- validar_limite(monto),
         comision = calcular_comision(tipo_cuenta, monto),
         :ok <- validar_saldo(monto, comision) do

      saldo_restante = @saldo_disponible - (monto + comision)
      billetes = calcular_billetes(monto)

      resultado = {monto, comision, saldo_restante, billetes}
      imprimir_comprobante({:ok, resultado})
      {:ok, resultado}
    else
      {:error, motivo} ->
        imprimir_comprobante({:error, motivo})
        {:error, motivo}
    end
  end

  defp validar_pin(pin) when byte_size(pin) == 4 and pin == @pin_correcto, do: :ok
  defp validar_pin(_), do: {:error, "PIN incorrecto o longitud inválida"}

  defp validar_cuenta("ahorros"), do: {:ok, :ahorros}
  defp validar_cuenta("corriente"), do: {:ok, :corriente}
  defp validar_cuenta(_), do: {:error, "Tipo de cuenta no válido"}

  defp validar_monto_positivo(monto) when monto > 0, do: :ok
  defp validar_monto_positivo(_), do: {:error, "El monto debe ser mayor a cero"}

  defp validar_multiplo(monto) when rem(monto, 10_000) == 0, do: :ok
  defp validar_multiplo(_), do: {:error, "El monto debe ser múltiplo de $10.000"}

  defp validar_limite(monto) when monto <= @limite_por_retiro, do: :ok
  defp validar_limite(_), do: {:error, "El monto supera el límite por retiro"}

  defp validar_saldo(monto, comision) when monto + comision <= @saldo_disponible, do: :ok
  defp validar_saldo(_, _), do: {:error, "Fondos insuficientes"}

  defp calcular_comision(:ahorros, monto) when monto <= 200_000, do: 0
  defp calcular_comision(:ahorros, _monto), do: 2_500
  defp calcular_comision(:corriente, _monto), do: 4_000

  defp calcular_billetes(monto) do
    b50 = div(monto, 50_000)
    resto50 = rem(monto, 50_000)

    b20 = div(resto50, 20_000)
    resto20 = rem(resto50, 20_000)

    b10 = div(resto20, 10_000)

    {b50, b20, b10}
  end

  defp imprimir_comprobante({:ok, {monto, comision, saldo, {b50, b20, b10}}}) do
    IO.puts("""
    --- COMPROBANTE DE RETIRO ---
    Retiro: $#{monto}
    Comisión: $#{comision}
    Saldo Restante: $#{saldo}
    Billetes entregados:
      $50.000: #{b50}
      $20.000: #{b20}
      $10.000: #{b10}
    """)
  end
  defp imprimir_comprobante({:error, motivo}), do: IO.puts("Transacción rechazada: #{motivo}")
end

# Ejecuta el programa
Cajero.main()
