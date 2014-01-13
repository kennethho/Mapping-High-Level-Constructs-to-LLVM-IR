int foo(int a, int b)
{
    int c = integer_parse();
    auto function = [](int x) { return (a + b - c) * x; }
    return function(10);
}
