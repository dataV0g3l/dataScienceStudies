using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;

namespace Singleton
{
    public class Worker
    {
        private Random rnd = new Random();

        public int DoWork()
        {
            int res = rnd.Next(10);

            Thread.Sleep(res * 1000);

            if (res == 3)
            {
                throw new Exception("PANIC!!!");
            }

            return res;
        }
    }
}
