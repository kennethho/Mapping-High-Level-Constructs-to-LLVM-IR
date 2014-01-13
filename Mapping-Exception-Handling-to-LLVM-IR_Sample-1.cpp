#include <stdio.h>
#include <stdlib.h>

struct Object
{
    virtual ~Object() {}
};

struct Exception : Object
{
    const char* text_;

    Exception(const char* text)
        :   text_(text)
    {
    }
    const char* GetText() const
    {
        return text_;
    }
};

class Foo
{
public:
    int GetLength() const
    {
        return _length;
    }

    void SetLength(int value)
    {
        _length = value;
    }

private:
    int _length;
};

int Bar(bool fail)
{
    Foo foo;
    foo.SetLength(17);
    if (fail)
        throw new Exception("Exception requested by caller");
    foo.SetLength(24);
    return foo.GetLength();
}

int main(int argc, const char *argv[])
{
    int result;

    try
    {
        /* The program throws an exception if an argument is specified. */
        bool fail = (argc >= 2);

        /* Let callee decide if an exception is thrown. */
        int value = Bar(fail);

        result = EXIT_SUCCESS;
    }
    catch (Exception *that)
    {
        printf("Error: %s\n", that->GetText());
        result = EXIT_FAILURE;
    }
    catch (...)
    {
        puts("Internal error: Unhandled exception detected");
        result = EXIT_FAILURE;
    }

    return result;
}
