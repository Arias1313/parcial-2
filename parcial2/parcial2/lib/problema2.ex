defmodule Terreno do
  defstruct [:simbolo, :nombre, :transitable, :costo]
end

defmodule RutaIsla do
  defstruct [:posiciones, :costo]
end

defmodule Problema2 do
  def validar_mapa(filas_matriz, mapa_terrenos) do
    errores = []

    ancho = rec_longitud(rec_cabeza(filas_matriz))
    errores = errores ++ rec_verificar_anchos(filas_matriz, ancho, 0, [])
    errores = errores ++ rec_verificar_simbolos(filas_matriz, mapa_terrenos, 0, [])

    {conteo_p, conteo_b} = rec_contar_pb(filas_matriz, 0, 0)
    errores = if conteo_p != 1, do: ["Debe haber exactamente 1 posición inicial 'P' (encontradas: #{conteo_p})" | errores], else: errores
    errores = if conteo_b != 1, do: ["Debe haber exactamente 1 bote 'B' (encontradas: #{conteo_b})" | errores], else: errores

    errores = errores ++ rec_verificar_bordes(filas_matriz, 0, rec_longitud(filas_matriz), ancho, [])
    errores
  end

  defp rec_cabeza([h | _]), do: h
  defp rec_cabeza([]), do: []

  defp rec_longitud([]), do: 0
  defp rec_longitud([_ | t]), do: 1 + rec_longitud(t)

  defp rec_verificar_anchos([], _ancho_ref, _idx, acc), do: acc
  defp rec_verificar_anchos([fila | tail], ancho_ref, idx, acc) do
    l = rec_longitud(fila)
    nuevos_acc = if l != ancho_ref, do: ["Fila #{idx}: Longitud inconsistente (tiene #{l}, se esperaban #{ancho_ref})" | acc], else: acc
    rec_verificar_anchos(tail, ancho_ref, idx + 1, nuevos_acc)
  end

  defp rec_verificar_simbolos([], _terrenos, _f_idx, acc), do: acc
  defp rec_verificar_simbolos([fila | tail], terrenos, f_idx, acc) do
    errs_fila = rec_verificar_simbolos_fila(fila, terrenos, f_idx, 0, [])
    rec_verificar_simbolos(tail, terrenos, f_idx + 1, acc ++ errs_fila)
  end

  defp rec_verificar_simbolos_fila([], _terrenos, _f, _c, acc), do: acc
  defp rec_verificar_simbolos_fila([sym | tail], terrenos, f, c, acc) do
    nuevo_acc = if not Map.has_key?(terrenos, sym), do: ["Posición (#{f}, #{c}): Símbolo '#{sym}' no definido en terrenos.csv" | acc], else: acc
    rec_verificar_simbolos_fila(tail, terrenos, f, c + 1, nuevo_acc)
  end

  defp rec_contar_pb([], p_acc, b_acc), do: {p_acc, b_acc}
  defp rec_contar_pb([fila | tail], p_acc, b_acc) do
    {p_f, b_f} = rec_contar_pb_fila(fila, 0, 0)
    rec_contar_pb(tail, p_acc + p_f, b_acc + b_f)
  end

  defp rec_contar_pb_fila([], p, b), do: {p, b}
  defp rec_contar_pb_fila(["P" | t], p, b), do: rec_contar_pb_fila(t, p + 1, b)
  defp rec_contar_pb_fila(["B" | t], p, b), do: rec_contar_pb_fila(t, p, b + 1)
  defp rec_contar_pb_fila([_ | t], p, b), do: rec_contar_pb_fila(t, p, b)

  defp rec_verificar_bordes([], _f_idx, _total_f, _total_c, acc), do: acc
  defp rec_verificar_bordes([fila | tail], f_idx, total_f, total_c, acc) do
    errs = rec_verificar_bordes_fila(fila, f_idx, 0, total_f, total_c, [])
    rec_verificar_bordes(tail, f_idx + 1, total_f, total_c, acc ++ errs)
  end

  defp rec_verificar_bordes_fila([], _f, _c, _tf, _tc, acc), do: acc
  defp rec_verificar_bordes_fila([sym | tail], f, c, tf, tc, acc) do
    es_borde = f == 0 or f == tf - 1 or c == 0 or c == tc - 1
    nuevo_acc = if es_borde and sym != "~", do: ["Posición de borde (#{f}, #{c}) contiene '#{sym}' en lugar de agua '~'" | acc], else: acc
    rec_verificar_bordes_fila(tail, f, c + 1, tf, tc, nuevo_acc)
  end

  def buscar_rutas(matriz, pos_actual, pos_bote, mapa_terrenos, visitados, costo_acc) do
    if pos_actual == pos_bote do
      [%RutaIsla{posiciones: Enum.reverse([pos_actual | visitados]), costo: costo_acc}]
    else
      {f, c} = pos_actual
      nuevos_visitados = [pos_actual | visitados]
      vecinos = [{f - 1, c}, {f + 1, c}, {f, c - 1}, {f, c + 1}]

      Enum.flat_map(vecinos, fn {vf, vc} ->
        sym = get_in_matriz(matriz, vf, vc)
        terreno = Map.get(mapa_terrenos, sym)

        if sym != nil and terreno != nil and terreno.transitable and {vf, vc} not in nuevos_visitados do
          buscar_rutas(matriz, {vf, vc}, pos_bote, mapa_terrenos, nuevos_visitados, costo_acc + terreno.costo)
        else
          []
        end
      end)
    end
  end

  defp get_in_matriz(matriz, f, c) when f >= 0 and c >= 0 do
    case Enum.at(matriz, f) do
      nil -> nil
      fila -> Enum.at(fila, c)
    end
  end
  defp get_in_matriz(_matriz, _f, _c), do: nil

def ejecutar do
    with {:ok, stream_terrenos} <- GestorArchivos.stream_lineas_limpias("terrenos.csv"),
         {:ok, stream_isla} <- GestorArchivos.stream_lineas_limpias("isla.txt") do

      mapa_terrenos =
        stream_terrenos
        |> Stream.map(fn linea ->
          [sym, nom, trans_str, costo_str] = String.split(linea, ",") |> Enum.map(&String.trim/1)
          trans = String.downcase(trans_str) in ["true", "1", "si"]

          costo = case Float.parse(costo_str) do
            {f, ""} -> f
            _ ->
              case Integer.parse(costo_str) do
                {i, ""} -> i * 1.0
                _ -> 0.0
              end
          end

          {sym, %Terreno{simbolo: sym, nombre: nom, transitable: trans, costo: costo}}
        end)
        |> Enum.into(%{})

      matriz_isla =
        stream_isla
        |> Stream.map(fn linea -> String.split(linea, " ") |> Enum.map(&String.trim/1) end)
        |> Enum.to_list()

      errores_mapa = validar_mapa(matriz_isla, mapa_terrenos)

      if errores_mapa != [] do
        GestorArchivos.escribir_lineas("validacion_isla.txt", errores_mapa)
        Util.imprimir_error("El mapa de la isla presenta errores. Revise 'validacion_isla.txt'.")
      else
        {pos_inicio, pos_bote} = encontrar_puntos(matriz_isla)
        rutas = buscar_rutas(matriz_isla, pos_inicio, pos_bote, mapa_terrenos, [], 0.0)

        lineas_csv =
          Enum.with_index(rutas, 1)
          |> Enum.map(fn {%RutaIsla{posiciones: pos, costo: c}, idx} ->
            movs = length(pos) - 1
            recorrido = Enum.map_join(pos, "->", fn {f, col} -> "(#{f},#{col})" end)
            "#{idx};#{movs};#{c};#{recorrido}"
          end)

        GestorArchivos.escribir_lineas("rutas_isla.csv", lineas_csv)
        generar_resumen(matriz_isla, rutas)
      end
    else
      {:error, msg} -> Util.imprimir_error(msg)
    end
  end

  defp encontrar_puntos(matriz) do
    Enum.with_index(matriz)
    |> Enum.reduce({nil, nil}, fn {fila, f}, acc ->
      Enum.with_index(fila)
      |> Enum.reduce(acc, fn
        {"P", c}, {_p, b} -> {{f, c}, b}
        {"B", c}, {p, _b} -> {p, {f, c}}
        _, acc_inner -> acc_inner
      end)
    end)
  end

  defp generar_resumen(matriz, rutas) do
    total = length(rutas)
    ruta_min = Enum.min_by(rutas, fn r -> length(r.posiciones) end)
    min_movs = length(ruta_min.posiciones) - 1
    rutas_mas_cortas = Enum.filter(rutas, fn r -> length(r.posiciones) - 1 == min_movs end)
    ruta_menor_costo = Enum.min_by(rutas, fn r -> r.costo end)

    mapa_marcado =
      Enum.with_index(matriz)
      |> Enum.map_join("\n", fn {fila, f} ->
        Enum.with_index(fila)
        |> Enum.map_join(" ", fn {sym, c} ->
          if {f, c} in ruta_menor_costo.posiciones and sym not in ["P", "B"] do
            "*"
          else
            sym
          end
        end)
      end)

    resumen = """
    =========================================
    RESUMEN DE ESCAPE DE LA ISLA
    =========================================
    Total de rutas encontradas: #{total}

    Ruta(s) más corta(s) (#{min_movs} movimientos):
    #{Enum.map_join(rutas_mas_cortas, "\n", fn r -> "  - Recorrido: " <> Enum.map_join(r.posiciones, "->", fn {f, c} -> "(#{f},#{c})" end) end)}

    Ruta de menor costo (Costo: #{ruta_menor_costo.costo}):
      - Recorrido: #{Enum.map_join(ruta_menor_costo.posiciones, "->", fn {f, c} -> "(#{f},#{c})" end)}

    Mapa con la ruta de menor costo marcada con (*):
    #{mapa_marcado}
    """

    File.write!("resumen_isla.txt", resumen)
    Util.imprimir_mensaje(resumen)
  end
end
