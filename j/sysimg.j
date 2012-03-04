## Load essential files and libraries

include("base.j")

show(e::LoadError) = (print("Load Error:"); show(e.error); show(e.file); show(e.line); print("\n"))
function show(e::TypeError)
    print("Type Error")
    if e.expected == Bool
        print("in bool")
    else
        if isa(e.got,Type)
            show(e.type)
        else
            show(typeof(e.got))
        end
    end
end

# core operations & types
include("range.j")
include("tuple.j")
include("cell.j")
include("expr.j")
include("error.j")

# core numeric operations & types
include("bool.j")
include("number.j")
include("int.j")
include("promotion.j")
include("operators.j")
include("float.j")
include("pointer.j")
include("char.j")
include("reduce.j")
include("complex.j")
include("rational.j")

# core data structures (used by type inference)
include("abstractarray.j")
include("subarray.j")
include("array.j")
include("intset.j")
include("table.j")
include("set.j")

# compiler
include("inference.j")

# I/O, strings & printing
include("io.j")
include("stream.j")
stream=make_stdout_stream()
set_current_output_stream(stream) # for error reporting
include("string.j")
include("ascii.j")
include("utf8.j")
include("regex.j")
include("show.j")
include("grisu.j")
include("printf.j")

# system & environment
include("libc.j")
include("env.j")
include("errno_h.j")

# core math functions
include("intfuncs.j")
include("floatfuncs.j")
include("math.j")
include("math_libm.j")
include("sort.j")
include("combinatorics.j")
include("statistics.j")

# concurrency and parallelism
include("iterator.j")
include("task.j")
include("serialize.j")
include("multi.j")
#include("multi-wip.j")

# front end
include("client.j")

# random number generation
#include("random.j")

# sparse matrices
include("sparse.j")

# distributed arrays
include("darray.j")

# utilities - version, timing, help, edit
include("version.j")
include("util.j")
include("datafmt.j")

## Load optional external libraries

# linear algebra
include("linalg.j")
include("linalg_blas.j")
include("linalg_lapack.j")
include("linalg_arpack.j")
include("linalg_suitesparse.j")

# signal processing
include("signal.j")
include("signal_fftw.j")


# prime method cache with some things we know we'll need right after startup
length(1:2:3)
(HashTable(0)[1])=()->()
numel(intset())
has(intset(),2)
del_all(FDSet())
start(HashTable(0))
done(HashTable(0),0)
get(HashTable(0), 0, ())
add(FDSet(),int32(0))
2==2.0
2.0==2.0
has(FDSet(),0)
isequal(int32(2),int32(2))
isequal(int64(2),int64(2))

compile_hint(getcwd, ())
compile_hint(fdio, (Int32,))
compile_hint(ProcessGroup, (Int, Array{Any,1}, Array{Any,1}))
compile_hint(select_read, (FDSet, Float64))
compile_hint(next, (HashTable{Any,Any}, Int))
compile_hint(start, (HashTable{Any,Any},))
compile_hint(perform_work, ())
compile_hint(isempty, (Array{Any,1},))
compile_hint(isempty, (Array{WorkItem,1},))
compile_hint(ref, (HashTable{Any,Any}, Int32))
compile_hint(event_loop, (Bool,))
compile_hint(_start, ())
compile_hint(_jl_color_available, ())
compile_hint(process_options, (Array{Any,1},))
compile_hint(run_repl, ())
compile_hint(anyp, (Any-->Any, Array{Any,1}))
compile_hint(HashTable, (Int,))
compile_hint(HashTable{Any,Any}, (Int,))
compile_hint(Set, ())
compile_hint(assign, (HashTable{Any,Any}, Bool, Cmd))
compile_hint(rehash, (HashTable{Any,Any}, Int))
compile_hint(run, (Cmd,))
compile_hint(spawn, (Cmd,))
#compile_hint(assign, (HashTable{Any,Any}, Bool, FileDes))
compile_hint(wait, (Int32,))
compile_hint(system_error, (ASCIIString, Bool))
compile_hint(SystemError, (ASCIIString,))
compile_hint(has, (EnvHash, ASCIIString))
compile_hint(parse_input_line, (ASCIIString,))
compile_hint(cmp, (Int32, Int32))
compile_hint(min, (Int32, Int32))
compile_hint(==, (ASCIIString, ASCIIString))
compile_hint(arg_gen, (ASCIIString,))
compile_hint(_jl_librandom_init, ())
compile_hint(srand, (ASCIIString, Int))
compile_hint(open, (ASCIIString, Bool, Bool, Bool, Bool))
compile_hint(srand, (Uint64,))
compile_hint(done, (IntSet, Int64))
compile_hint(next, (IntSet, Int64))
compile_hint(ht_keyindex, (HashTable{Any,Any}, Int32))
compile_hint(perform_work, (WorkItem,))
compile_hint(notify_done, (WorkItem,))
compile_hint(work_result, (WorkItem,))
compile_hint(del_io_handler, (Int32,))
compile_hint(enqueue, (Array{WorkItem,1}, WorkItem))
compile_hint(enq_work, (WorkItem,))
compile_hint(pop, (Array{WorkItem,1},))
compile_hint(string, (Int,))
compile_hint(parse_int, (Type{Int}, ASCIIString, Int))
compile_hint(repeat, (ASCIIString, Int))
compile_hint(KeyError, (Int,))
compile_hint(show, (Float64,))
compile_hint(match, (Regex, ASCIIString))
compile_hint(strlen, (ASCIIString,))
compile_hint(dims2string, (Tuple,))
compile_hint(alignment, (Float64,))
compile_hint(repl_callback, (Expr, Int))
compile_hint(istaskdone, (Task,))
compile_hint(make_stdout_stream, ())
compile_hint(set_current_output_stream, (AsyncStream,))
compile_hint(int, (Uint64,))
compile_hint(copy, (Bool,))
compile_hint(bool, (Bool,))
compile_hint(bool, (RemoteRef,))
compile_hint(wait, (RemoteRef,))
compile_hint(hash, (RemoteRef,))
compile_hint(take, (RemoteRef,))
compile_hint(bitmix, (Int, Int))
compile_hint(bitmix, (Uint, Int))
compile_hint(bitmix, (Uint64, Int64))
compile_hint(hash, (Int,))
compile_hint(isequal, (Symbol, Symbol))
compile_hint(isequal, (Bool, Bool))
compile_hint(WaitFor, (Symbol, RemoteRef))
compile_hint(_jl_answer_color, ())
compile_hint(get, (EnvHash, ASCIIString, ASCIIString))
compile_hint(notify_empty, (WorkItem,))
compile_hint(rr2id, (RemoteRef,))
compile_hint(isequal, (RemoteRef, WeakRef))
compile_hint(isequal, (RemoteRef, RemoteRef))
compile_hint(_ieval, (Symbol,))
compile_hint(static_convert, (Any, Any))
compile_hint(assign, (Array{Any,1}, WeakRef, Int))
compile_hint(hash, (Tuple,))
compile_hint(assign, (HashTable{Any,Any}, WorkItem, (Int,Int)))
compile_hint(isequal, ((Int,Int),(Int,Int)))
compile_hint(RemoteRef, (Int, Int, Int))
compile_hint(inlining_pass, (LambdaStaticData, Array{Any,1}))
compile_hint(_jl_eval_user_input, (Expr, Bool))
compile_hint(print, (Float64,))
compile_hint(remove_call1, (Expr,))
compile_hint(a2t, (Array{Any,1},))
compile_hint(flush, (IOStream,))
compile_hint(ref, (Type{String}, ASCIIString, ASCIIString, ASCIIString))
