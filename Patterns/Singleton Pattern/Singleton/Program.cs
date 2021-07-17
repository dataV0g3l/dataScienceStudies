using System;
using System.Threading.Tasks;

namespace Singleton
{
    class Program
    {
        static void Main(string[] args)
        {
            Parallel.For(0, 10, new ParallelOptions { MaxDegreeOfParallelism = 10 }, (int i) => {
                Worker worker = new Worker();
                try
                {
                    int res = worker.DoWork();
                    Console.WriteLine(res);
                    HealthState.GetInstance().TaskFinished(res);
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.Message);
                    HealthState.GetInstance().TaskFailed(ex.Message);
                }
            });

            Console.WriteLine(HealthState.GetInstance().GetTextReport());
        }
    }
}
