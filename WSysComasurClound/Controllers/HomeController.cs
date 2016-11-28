using WSysComasurClound.Models;
using System.Linq;
using System.Web.Mvc;
using System.Web.Script.Serialization;

namespace WSysComasurClound.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        private WSysComasurCloundEntities db = new WSysComasurCloundEntities();
        public ActionResult Index()
        {
            return View();
        }

        [Authorize]
        public ActionResult Contact()
        {
            return View();
        }

        [ChildActionOnly]
        public ActionResult LoadMenu()
        {
            var menu = from a in db.MenuTemp
                               select a;
            return View(menu.ToList());
        }


    }
}