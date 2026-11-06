defmodule Conexion do
  defstruct [:origen, :destino, :distancia]

  def parse(linea, num_linea) do
    case String.split(linea, ",") |> Enum.map(&String.trim/1) do
      [origen, destino, dist_str] ->
        case Float.parse(dist_str) do
          {dist, ""} ->
            {:ok, %Conexion{origen: origen, destino: destino, distancia: dist}}

          _ ->
            case Integer.parse(dist_str) do
              {dist, ""} -> {:ok, %Conexion{origen: origen, destino: destino, distancia: dist * 1.0}}
              _ -> {:error, "Línea #{num_linea}: '#{linea}' -> Distancia no numérica"}
            end
        end

      _ ->
        {:error, "Línea #{num_linea}: '#{linea}' -> Campos faltantes o formato inválido"}
    end
  end
end

defmodule Ruta do
  defstruct [:ciudades, :distancia]
end

defmodule Problema1 do
  def depurar_conexiones(lista_conexiones) do
    depurar_rec(lista_conexiones, [], [])
  end

  defp depurar_rec([], acumu_validas, reportes) do
    {reverse_lista(acumu_validas, []), reverse_lista(reportes, [])}
  end

  defp depurar_rec([%Conexion{origen: c, destino: c} = _conn | tail], acumu_validas, reportes) do
    msg = "Conexión de la ciudad '#{c}' consigo misma descartada (%Conexion{origen: #{c}, destino: #{c}})."
    depurar_rec(tail, acumu_validas, [msg | reportes])
  end

  defp depurar_rec([conn | tail], acumu_validas, reportes) do
    case buscar_existente(conn, acumu_validas) do
      :no_existe ->
        depurar_rec(tail, [conn | acumu_validas], reportes)

      :igual ->
        msg = "Conexión duplicada entre #{conn.origen} y #{conn.destino} descartada."
        depurar_rec(tail, acumu_validas, [msg | reportes])

      :distinta_distancia ->
        msg = "Conexión entre #{conn.origen} y #{conn.destino} con distancia distinta descartada (se conserva la primera)."
        depurar_rec(tail, acumu_validas, [msg | reportes])
    end
  end

  defp buscar_existente(_conn, []), do: :no_existe
  defp buscar_existente(%Conexion{origen: o, destino: d, distancia: dist}, [%Conexion{origen: o2, destino: d2, distancia: dist2} | _tail])
       when (o == o2 and d == d2) or (o == d2 and d == o2) do
    if dist == dist2, do: :igual, else: :distinta_distancia
  end
  defp buscar_existente(conn, [_head | tail]), do: buscar_existente(conn, tail)

  defp reverse_lista([], acc), do: acc
  defp reverse_lista([h | t], acc), do: reverse_lista(t, [h | acc])

  def obtener_pasos_alcance(origen, grafo) do
    initial_set = MapSet.new([origen])
    get_alcance_rec(initial_set, nil, grafo, [])
  end

  defp get_alcance_rec(actuales, previos, grafo, acc) do
    cond do
      previos != nil and MapSet.equal?(actuales, previos) ->
        Enum.reverse([{:repetido, actuales} | acc])

      true ->
        nuevos_vecinos =
          actuales
          |> Enum.reduce(MapSet.new(), fn ciudad, inner_acc ->
            vecinos = Map.get(grafo, ciudad, []) |> Enum.map(fn {v, _d} -> v end) |> MapSet.new()
            MapSet.union(inner_acc, vecinos)
          end)

        siguiente_actuales = MapSet.union(actuales, nuevos_vecinos)
        get_alcance_rec(siguiente_actuales, actuales, grafo, [{:paso, actuales} | acc])
    end
  end

  def buscar_rutas(origen, destino, grafo) do
    buscar_rutas_rec(origen, destino, grafo, [origen], 0.0)
  end

  defp buscar_rutas_rec(actual, destino, _grafo, camino, dist_acc) when actual == destino do
    [%Ruta{ciudades: Enum.reverse(camino), distancia: dist_acc}]
  end

  defp buscar_rutas_rec(actual, destino, grafo, camino, dist_acc) do
    vecinos = Map.get(grafo, actual, [])

    Enum.flat_map(vecinos, fn {vecino, dist} ->
      if vecino in camino do
        []
      else
        buscar_rutas_rec(vecino, destino, grafo, [vecino | camino], dist_acc + dist)
      end
    end)
  end

  def ejecutar do
    case GestorArchivos.stream_lineas_limpias("conexiones.csv") do
      {:error, msg} ->
        Util.imprimir_error(msg)

      {:ok, stream_conn} ->
        {conexiones_validas, errores_conn} =
          stream_conn
          |> Stream.with_index(1)
          |> Stream.map(fn {linea, idx} -> Conexion.parse(linea, idx) end)
          |> Enum.reduce({[], []}, fn
            {:ok, conn}, {val, err} -> {[conn | val], err}
            {:error, e}, {val, err} -> {val, [e | err]}
          end)

        GestorArchivos.escribir_lineas("errores_conexiones.txt", Enum.reverse(errores_conn))

        {conexiones_depuradas, reportes_dep} = depurar_conexiones(Enum.reverse(conexiones_validas))
        GestorArchivos.escribir_lineas("depuracion_conexiones.txt", reportes_dep)

        grafo =
          Enum.reduce(conexiones_depuradas, %{}, fn %Conexion{origen: o, destino: d, distancia: dist}, g ->
            g
            |> Map.update(o, [{d, dist}], &[{d, dist} | &1])
            |> Map.update(d, [{o, dist}], &[{o, dist} | &1])
          end)

        case GestorArchivos.stream_lineas_limpias("consultas.txt") do
          {:error, msg_c} ->
            Util.imprimir_error(msg_c)

          {:ok, stream_consultas} ->
            archivo_rutas = File.open!("rutas_encontradas.txt", [:write, :utf8])
            archivo_alcance = File.open!("alcance.txt", [:write, :utf8])

            stream_consultas
            |> Stream.each(fn linea ->
              case String.split(linea, ",") |> Enum.map(&String.trim/1) do
                [origen, destino] ->
                  IO.puts(archivo_alcance, "=== ALCANCE DESDE: #{origen} HASTA: #{destino} ===")
                  pasos = obtener_pasos_alcance(origen, grafo)

                  Enum.with_index(pasos)
                  |> Enum.each(fn
                    {{:paso, conjunto}, i} ->
                      IO.puts(archivo_alcance, "Paso #{i}: #{Enum.join(MapSet.to_list(conjunto), ", ")}")

                    {{:repetido, conjunto}, i} ->
                      IO.puts(archivo_alcance, "Paso #{i} (Estabilizado): #{Enum.join(MapSet.to_list(conjunto), ", ")}")
                  end)

                  {_, conjunto_final} = List.last(pasos)

                  cond do
                    not Map.has_key?(grafo, origen) or not Map.has_key?(grafo, destino) ->
                      msg = "Consulta #{origen} -> #{destino}: Una o ambas ciudades no existen en el grafo."
                      Util.imprimir_error(msg)
                      IO.puts(archivo_rutas, msg)

                    not MapSet.member?(conjunto_final, destino) ->
                      msg = "Consulta #{origen} -> #{destino}: Sin rutas disponibles (Destino no alcanzable)."
                      Util.imprimir_error(msg)
                      IO.puts(archivo_rutas, msg)

                    true ->
                      rutas = buscar_rutas(origen, destino, grafo)
                      escribir_resumen_rutas(origen, destino, rutas, archivo_rutas)
                  end

                _ ->
                  :ok
              end
            end)
            |> Stream.run()

            File.close(archivo_rutas)
            File.close(archivo_alcance)
        end
    end
  end

  defp escribir_resumen_rutas(origen, destino, rutas, archivo) do
    encabezado = "\n=========================================\nRUTAS DE #{origen} A #{destino}\n========================================="
    Util.imprimir_mensaje(encabezado)
    IO.puts(archivo, encabezado)

    Enum.with_index(rutas, 1)
    |> Enum.each(fn {%Ruta{ciudades: c, distancia: d}, idx} ->
      info = "Ruta #{idx}: #{Enum.join(c, " -> ")} | Ciudades: #{length(c)} | Distancia Total: #{d}"
      Util.imprimir_mensaje(info)
      IO.puts(archivo, info)
    end)

    total = length(rutas)
    ruta_min = Enum.min_by(rutas, fn r -> length(r.ciudades) end)
    min_ciudades = length(ruta_min.ciudades)
    rutas_mas_cortas = Enum.filter(rutas, fn r -> length(r.ciudades) == min_ciudades end)
    ruta_menor_dist = Enum.min_by(rutas, fn r -> r.distancia end)

    resumen = """
    Total rutas encontradas: #{total}
    Ruta(s) que visita(n) menos ciudades (#{min_ciudades} ciudades):
    #{Enum.map_join(rutas_mas_cortas, "\n", fn r -> "  - " <> Enum.join(r.ciudades, " -> ") end)}
    Ruta con menor distancia total (#{ruta_menor_dist.distancia}):
      - #{Enum.join(ruta_menor_dist.ciudades, " -> ")}
    """

    Util.imprimir_mensaje(resumen)
    IO.puts(archivo, resumen)
  end
end
