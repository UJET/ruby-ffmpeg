require 'benchmark'
require 'set'


# Find if number is there in the array
def random_search( numbers, search_term )
    #puts "Searching for #{search_term} : is it present? #{numbers.include? search_term}"
    size = numbers.size
    random_array = Array.new(size){ |k| k }
    cnt = 0
    loop{
        index   = random_array.shift
        cnt += 1;
        return [true, cnt]   if numbers[index] == search_term
        return [false, cnt] if cnt == size
    }
end

def parallel_search( numbers, search_term )
    size = numbers.size
    find = 0
    t = []
    cnt = Array.new(10){ 0 }
    (0..9).each do | i |
        t << Thread.new{
            found, cnt[i] = random_search( numbers[i*size/10..(i+1)*size/10 - 1],  search_term)
            find +=1 if found
        }
     end
     if find > 0
        t.each do | threads | t.kill end
     end
     t.each do | threads |
         threads.join
     end
     return [find > 0, cnt.reduce(:+)]
end

    
    
def binary_search( numbers, search_term )
    sorted = numbers.sort
    min = 0
    max = sorted.size - 1
    cnt = 0
    loop{
        check = (min + max) / 2
        cnt += 1;
        return true,cnt  if sorted[check] == search_term
        return false,cnt if min >= max
        min = check + 1 if sorted[check] < search_term
        max = check  if sorted[check] > search_term
    }
end


# Ruby inbuilt search
def ruby_find numbers, search_term
    numbers.include? search_term
end
    
begin
sizes = [10,100,1000,10000,100000,1000000,10000000,100000000,1000000000]
expt_count = 1000
results        = []
results_random = []
results_parallel=[]
results_bin    = []
search_terms   = []
sizes.each do | cur_size |
  result = Benchmark.bm(7) do | x |
     numbers     = Array.new(cur_size){ rand(0..2*cur_size) }
     expt_count.times do  search_terms << numbers.sample end
     x.report("      ruby_inbuilt:")  { expt_count.times { |i| search_term = search_terms[i]; ruby_find(numbers, search_term) } }
     x.report("     random_search:")  { expt_count.times { |i| search_term = search_terms[i]; results_random << random_search(numbers, search_term) } } 
     x.report("binary_search_ruby:")  { expt_count.times { |i| search_term = search_terms[i]; results_bin << binary_search(numbers, search_term) } } 
     x.report("parallel_random_sr:")  { expt_count.times { |i| search_term = search_terms[i]; results_parallel << parallel_search(numbers, search_term) } }
  end
end

   found     = { "random" => [], "binary" => [], "ruby" => [], "parallel" => [] }
   not_found = { "random" => [], "binary" => [], "ruby" => [], "parallel" => [] }
   results_random.each do | random_entry |
     ( random_entry[0] ? found["random"] : not_found["random"] ) << random_entry[1]
   end
   results_parallel.each do | parallel_entry |
     ( parallel_entry[0] ? found["parallel"] : not_found["parallel"] ) << parallel_entry[1]
   end
   results_bin.each do | binary_entry |
     ( binary_entry[0] ? found["binary"] : not_found["binary"] ) << binary_entry[1]
   end
   results.each do | ruby_way |
        if ruby_way
            found["ruby"] << true
        else
            not_found["ruby"] << false
        end
    end
    printf "--------------------------------------------------------------------------------------------\n"
    printf " %20s | %20s | %20s | %20s | \n","what", "random", "binary", "ruby"
    printf "--------------------------------------------------------------------------------------------\n"
    printf " %20s | %20s | %20s | %20s | \n",    "found",          found["random"].size,          found["binary"].size,     found["ruby"].size
    printf " %20s | %20s | %20s | %20s | \n","not found",      not_found["random"].size,      not_found["binary"].size, not_found["ruby"].size
    printf " %20s | %9s(%9s) | %9s(%9s) | %20s | \n","foundsteps", found["random"].reduce(:+), found["random"].reduce(:+)/found["random"].size , found["binary"].reduce(:+), found["binary"].reduce(:+)/found["binary"].size, found["ruby"].size
    printf " %20s | %20s | %20s | %20s | \n","not_foundsteps", not_found["random"].reduce(:+)/not_found["random"].size,not_found["binary"].reduce(:+)/not_found["random"].size, not_found["ruby"].size
end
