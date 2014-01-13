int foo(int a)
{
    auto function = [](int x) { return x + a; }
    return function(10);
}
