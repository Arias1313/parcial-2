defmodule Cupon do

  def main do
    cupon = Util.leer("Ingrese el cupón promocional: ", :string)

    validar(cupon)
    |> imprimir_resultado()
  end


  def validar(cupon) do
    {cupon, ""}
    |> validar_longitud()
    |> validar_mayuscula()
    |> validar_numero()
    |> validar_espacios()
    |> construir_resultado()
  end


  defp agregar_error("", nuevo_error), do: nuevo_error
  defp agregar_error(errores, nuevo_error), do: errores <> ", " <> nuevo_error

  defp validar_longitud({cupon, errores}) do
    if String.length(cupon) >= 10 do
      {cupon, errores}
    else
      {cupon, agregar_error(errores, "debe tener al menos 10 caracteres")}
    end
  end


  defp validar_mayuscula({cupon, errores}) do
    if cupon != String.downcase(cupon) do
      {
        cupon, errores
      }
    else
      {
        cupon, agregar_error(errores, "debe contener al menos una letra mayúscula")
      }
    end
  end

  defp validar_numero({cupon, errores}) do

    numeros = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

    if String.contains?(cupon, numeros) do
      {cupon, errores}
    else
      {cupon, agregar_error(errores, "debe contener al menos un número")}
    end
  end

  defp validar_espacios({cupon, errores}) do
    if String.contains?(cupon, " ") do
      {cupon, agregar_error(errores, "no debe contener espacios en blanco")}
    else
      {cupon, errores}
    end
  end


  defp construir_resultado({_, ""}), do: {:ok, "Cupón válido"}
  defp construir_resultado({_, errores}), do: {:error, errores}


  defp imprimir_resultado({:ok, mensaje}) do
    Util.imprimir_mensaje("Exito: #{mensaje}")
  end

  defp imprimir_resultado({:error, mensaje}) do
    Util.imprimir_mensaje("Error: #{mensaje}")
  end
end


Cupon.main()
