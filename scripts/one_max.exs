# Well be solving the One-Max problem described in the docs for

# - N = 1000
# - A nice population size will be 100

population = for _ <- 1..100, do: for(_ <- 1..1000, do: Enum.random(0..1))

# This function takes a population, evaluates each
# chromosome based on a fitness function, and sorts the population based on
# each chromosome’s fitness.
evaluate = fn population ->
  Enum.sort_by(population, &Enum.sum/1, &>=/2)
end

# Pair parents, with more or less the same fitness together, which is not always
# a good idea
selection = fn population ->
  population
  |> Enum.chunk_every(2)
  |> Enum.map(&List.to_tuple(&1))
end

crossover = fn population ->
  Enum.reduce(population, [], fn {p1, p2}, acc ->
    cx_point = :rand.uniform(1000)
    {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
    [h1 ++ t2, h2 ++ t1 | acc]
  end)
end

mutation = fn population ->
  population
  |> Enum.map(fn chromosome ->
    if :rand.uniform() < 0.05 do
      Enum.shuffle(chromosome)
    else
      chromosome
    end
  end)
end

algorithm = fn population, algorithm, iteration ->
  best = Enum.max_by(population, &Enum.sum/1)
  IO.write("\rCurrent Best: " <> Integer.to_string(Enum.sum(best)))

  if Enum.sum(best) == 1000 do
    {iteration, best}
  else
    # Initial Population
    population
    # Evaluate Population
    |> evaluate.()
    # Select Parents
    |> selection.()
    # Create Children
    |> crossover.()
    # Repeat the Process with new Population
    |> mutation.()
    |> algorithm.(algorithm, iteration + 1)
  end
end

{iterations, solution} = algorithm.(population, algorithm, 0)
IO.write("\n Answer is \n")
IO.inspect(solution)
IO.write("\n It took iterations \n")
IO.inspect(iterations)
