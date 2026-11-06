defmodule Agencia do
  @moduledoc """
  Calcula el valor de un paquete turístico combinando vuelo y alojamiento.
  """
  @bogota 180_000.0
  @medellin 150_000.0
  @cartagena 220_000.0
  @san_andres 280_000.0
  @maleta 45_000.0
  @seguro_noche 12_000.0

  def main do
    destino = Util.leer("Destino (1. Bogotá, 2. Medellín, 3. Cartagena, 4. San Andrés): ", :integer)
    noches = Util.leer("Número de noches: ", :integer)
    cliente = Util.leer("Tipo de cliente (frecuente/corporativo/ocasional): ", :string)
    mes = Util.leer("Mes (1 a 12): ", :integer)
    maleta = Util.leer("¿Desea maleta de bodega? (si/no): ", :string)
    seguro = Util.leer("¿Desea seguro de viaje? (si/no): ", :string)

    cotizar(destino, noches, cliente, mes, maleta, seguro)
    |> imprimir_recibo()
  end

  def cotizar(destino, noches, cliente, mes, equipaje, seguro_input) do
    with {:ok, dest} <- validar_rango(destino, 1, 4, "Destino no válido"),
         {:ok, n} <- validar_rango(noches, 1, 30, "Noches fuera de límite"),
         {:ok, m} <- validar_rango(mes, 1, 12, "Mes inexistente"),
         {:ok, tipo_cliente} <- validar_cliente(String.downcase(cliente)) do

      vuelo = tarifa_vuelo(dest)
      {valor_maleta, origen_maleta} = calcular_maleta(dest, String.downcase(equipaje))

      t_noche = tarifa_noche(n)
      subtotal_hotel = t_noche * n
      descuento = subtotal_hotel * descuento_cliente(tipo_cliente)
      hotel_descontado = subtotal_hotel - descuento
      recargo = hotel_descontado * recargo_mes(m)

      seguro = si_o_no(seguro_input) * (@seguro_noche * n)
      base_descuento = hotel_descontado + recargo + seguro
      descuento_paquete = if n >= 3, do: base_descuento * 0.05, else: 0.0

      total = vuelo + valor_maleta + base_descuento - descuento_paquete

      {:ok,
       {vuelo, valor_maleta, origen_maleta},
       {t_noche, subtotal_hotel, descuento, recargo},
       {seguro, descuento_paquete, total}}
    end
  end

  defp tarifa_vuelo(1), do: @bogota
  defp tarifa_vuelo(2), do: @medellin
  defp tarifa_vuelo(3), do: @cartagena
  defp tarifa_vuelo(4), do: @san_andres

  defp calcular_maleta(4, _), do: {@maleta, :automatico}
  defp calcular_maleta(_, "si"), do: {@maleta, :solicitado}
  defp calcular_maleta(_, _), do: {0.0, :no_aplica}

  defp tarifa_noche(noches) when noches >= 1 and noches <= 2, do: 120_000.0
  defp tarifa_noche(noches) when noches >= 3 and noches <= 5, do: 100_000.0
  defp tarifa_noche(noches) when noches >= 6 and noches <= 30, do: 85_000.0

  defp descuento_cliente(:frecuente), do: 0.20
  defp descuento_cliente(:corporativo), do: 0.15
  defp descuento_cliente(:ocasional), do: 0.0

  defp recargo_mes(mes) do
    cond do
      mes in [12, 1] -> 0.25
      mes in [6, 7] -> 0.10
      true -> 0.0
    end
  end

  defp validar_rango(val, min, max, _) when val >= min and val <= max, do: {:ok, val}
  defp validar_rango(_, _, _, error), do: {:error, error}

  defp validar_cliente("frecuente"), do: {:ok, :frecuente}
  defp validar_cliente("corporativo"), do: {:ok, :corporativo}
  defp validar_cliente("ocasional"), do: {:ok, :ocasional}
  defp validar_cliente(_), do: {:error, "Tipo de cliente inválido"}

  defp si_o_no(respuesta), do: if(String.downcase(respuesta) == "si", do: 1.0, else: 0.0)

  defp formato_pesos(monto), do: :erlang.float_to_binary(monto / 1, [decimals: 2])

  def imprimir_recibo({:ok, {v, val_m, orig_m}, {t_n, sub_h, desc, rec}, {seg, desc_p, tot}}) do
    IO.puts("""
    ==============================
    Vuelo: $#{formato_pesos(v)}
    Maleta: $#{formato_pesos(val_m)} (#{orig_m})
    ---
    Noches (Tarifa): $#{formato_pesos(t_n)}
    Hotel Base: $#{formato_pesos(sub_h)}
    Descuento Cliente: -$#{formato_pesos(desc)}
    Recargo Temporada: +$#{formato_pesos(rec)}
    ---
    Seguro de viaje: $#{formato_pesos(seg)}
    Descuento Paquete: -$#{formato_pesos(desc_p)}
    ==============================
    TOTAL: $#{formato_pesos(tot)}
    """)
  end
  def imprimir_recibo({:error, motivo}), do: IO.puts("Error: #{motivo}")
end

# Ejecuta el programa
Agencia.main()
